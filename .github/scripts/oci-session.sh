#!/usr/bin/env bash
# Exchanges the GitHub OIDC token of this job for OCI session tokens (UPST)
# and writes ~/.oci/config with one profile per account:
#   DEFAULT    account A (OCI_REGION_A, OCI_DOMAIN_A, OCI_TENANCY_A, OCI_CLIENT_A)
#   account_b  account B (OCI_REGION_B, OCI_DOMAIN_B, OCI_TENANCY_B, OCI_CLIENT_B),
#              only if OCI_TENANCY_B is set
# OCI_CLIENT_* is "client_id:client_secret" of the github-terraform app.
# The job needs "permissions: id-token: write".
# A session token expires after about an hour, so a background loop gets new
# tokens every 15 minutes until the job ends.
set -euo pipefail
umask 077

# the values of account A are required, see README.md
: "${OCI_REGION_A:?}" "${OCI_TENANCY_A:?}" "${OCI_DOMAIN_A:?}" "${OCI_CLIENT_A:?}"
# with OCI_TENANCY_B, the values of account B are required too
if [ -n "${OCI_TENANCY_B:-}" ]; then
  : "${OCI_REGION_B:?}" "${OCI_DOMAIN_B:?}" "${OCI_CLIENT_B:?}"
fi

dir=$HOME/.oci

new_key() {
  local profile=$1
  openssl genrsa -out "$dir/$profile.pem" 2048 2> /dev/null
  openssl rsa -in "$dir/$profile.pem" -pubout -outform DER 2> /dev/null \
    | openssl base64 -A > "$dir/$profile.pub"
  openssl base64 -d -A < "$dir/$profile.pub" | openssl dgst -md5 -c | awk '{print $NF}'
}

exchange() {
  local profile=$1 domain=$2 client=$3 jwt response
  jwt=$(curl -fsS --retry 3 \
    -H "Authorization: Bearer $ACTIONS_ID_TOKEN_REQUEST_TOKEN" \
    "$ACTIONS_ID_TOKEN_REQUEST_URL&audience=https%3A%2F%2Fcloud.oracle.com" \
    | jq -er .value)
  # the client secret goes through stdin, not the command line
  if ! response=$(curl -sS --fail-with-body --retry 3 -K - \
    --data-urlencode 'grant_type=urn:ietf:params:oauth:grant-type:token-exchange' \
    --data-urlencode 'requested_token_type=urn:oci:token-type:oci-upst' \
    --data-urlencode 'subject_token_type=jwt' \
    --data-urlencode "subject_token=$jwt" \
    --data-urlencode "public_key@$dir/$profile.pub" \
    "$domain/oauth2/v1/token" <<< "user = \"$client\""); then
    # an error response has no token
    echo "token exchange failed for $profile: $response" >&2
    return 1
  fi
  # no newline after the token, the Go SDK puts the file as-is into the Authorization header
  jq -je .token <<< "$response" > "$dir/$profile.token.next"
  mv "$dir/$profile.token.next" "$dir/$profile.token"
}

profile() {
  local name=$1 tenancy=$2 region=$3 fingerprint
  fingerprint=$(new_key "$name")
  cat >> "$dir/config" << EOT
[$name]
tenancy=$tenancy
region=$region
fingerprint=$fingerprint
key_file=$dir/$name.pem
security_token_file=$dir/$name.token

EOT
}

exchange_all() {
  exchange DEFAULT "$OCI_DOMAIN_A" "$OCI_CLIENT_A"
  if [ -n "${OCI_TENANCY_B:-}" ]; then
    exchange account_b "$OCI_DOMAIN_B" "$OCI_CLIENT_B"
  fi
}

mkdir -p "$dir"
: > "$dir/config"
profile DEFAULT "$OCI_TENANCY_A" "$OCI_REGION_A"
if [ -n "${OCI_TENANCY_B:-}" ]; then
  profile account_b "$OCI_TENANCY_B" "$OCI_REGION_B"
fi

exchange_all
echo "OCI session tokens written for: $(grep -o '^\[[^]]*\]' "$dir/config" | tr -d '[]' | xargs)"

# the runner stops this loop when the job ends
nohup bash -c "$(declare -f exchange exchange_all); dir=$dir; set -euo pipefail
  while sleep 900; do exchange_all || echo \"renewal failed at \$(date)\"; done" > "$dir/renew.log" 2>&1 &
