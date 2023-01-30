#!/usr/bin/env bash

fetch_manifest() {
  local fn="backdoor.yaml"

  if [[ -r "$fn" ]]
  then
    cat "$fn"
    return
  fi

  local url="https://raw.githubusercontent.com/pschmitt/tailscale-backdoor/main/${fn}"
  wget -O- "$url"
}

patch_auth_key() {
  local ts_auth_key="${1:-${TS_AUTHKEY}}"
  local manifest="${2:-${MANIFEST}}"

  TS_AUTHKEY="${ts_auth_key}" \
    yq --inplace --exit-status \
      'select(.kind == "Secret" and .metadata.name == "tailscale-auth") |=
      .stringData.TS_AUTHKEY=env(TS_AUTHKEY)' \
      "$manifest"
}

patch_hostname() {
  local ts_hostname="${1:-${TS_HOSTNAME}}"
  local manifest="${2:-${MANIFEST}}"

  TS_HOSTNAME="${ts_hostname}" \
    yq --inplace --exit-status \
      'select(.kind == "Deployment" and .metadata.name == "tailscale-backdoor") |=
       .spec.template.spec.containers[] |=
       select(.name == "tailscale").env[] |=
       select(.name == "TS_HOSTNAME").value = env(TS_HOSTNAME)' \
      "$manifest"
}

patch_owner() {
  local owner="${1:-${OWNER}}"
  local manifest="${2:-${MANIFEST}}"

  OWNER="${owner}" \
    yq --inplace --exit-status \
      'select(.kind == "Deployment") |=
      .metadata.labels.owner = env(OWNER) | 
      .spec.template.metadata.labels.owner = env(OWNER)' \
      "$manifest"
}

while [[ -n "$*" ]]
do
  case "$1" in
    --key|--auth-key|--auth|--authkey)
      TS_AUTH_KEY="$2"
      shift 2
      ;;
    --hostname|--host|-H)
      TS_HOSTNAME="$2"
      shift 2
      ;;
    --owner|-o)
      OWNER="$2"
      shift 2
      ;;
  esac
done

OWNER="${OWNER:-${USER}}"

MANIFEST="$(mktemp --dry-run --suffix .yaml)"
fetch_manifest > "$MANIFEST"

if [[ -n "$TS_AUTH_KEY" ]]
then
  patch_auth_key "$TS_AUTH_KEY"
fi

if [[ -n "$TS_HOSTNAME" ]]
then
  patch_hostname "$TS_HOSTNAME"
fi

if [[ -n "$OWNER" ]]
then
  patch_owner "$OWNER"
fi

echo "Manifest path: $MANIFEST" >&2
yq "$MANIFEST"
