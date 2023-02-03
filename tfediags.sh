#!/usr/bin/env bash

set -e

error() {
  printf "\u001b[31m[ERROR]\u001b[0m %s" "$1"
  echo
  exit 1
}

info() {
  printf "\u001b[32m[INFO]\u001b[0m  %s" "$1"
  echo
}

debug() {
  if [ "$LOG" != "DEBUG" ]; then
    return
  fi
  printf "\u001b[90m[DEBUG]\u001b[0m %s" "$1"
  echo
}

print_usage() {
  echo "Usage: $0 <hostname>"
  echo "  example: $0 prod.tfe.engineering"
  exit 1
}

# Checks if the given argument is an executable command
prereq() {
  if ! command -v "$1" &> /dev/null; then
    error "$1 is a prerequisite of this script but was not found."
  fi
  debug "$($1 --version | head -1)"
}

# Extracts a token credential for the given hostname from the default credentials file
extract_token () {
  jq '.credentials.'\"$1\"'.token' -r "$HOME/.terraform.d/credentials.tfrc.json"
}

# Ensure prerequisites
prereq "jq"
prereq "curl"

# Ensure hostname is given as flags
hostname=$1
if [ -z "$hostname" ]; then
  print_usage
fi

# Ensure token exists for given hostname
token=$(extract_token "$1")
if [ -z "$token" ] || [ "$token" == "null" ]; then
  error "No credentials found for $1. Use terraform login <hostname> to ensure a token is stored in the default credentials directory, which is \"$HOME/.terraform.d\". Please ensure that you login using a site admin user."
fi

path=$(curl --fail -s -H "Authorization: Bearer $token" "https://$hostname/.well-known/terraform.json" | jq -r '."tfe.v2"')
debug "TFE service discovery tfe.v2: $path"

diagid="tfe-diags-$(date +%Y%m%d_%H%M%SZ)"
mkdir -p "$diagid"

# Fetch terraform versions
page="1"
while [[ $page != "null" ]]; do
  info "Fetching page $page of terraform versions from https://${hostname}${path}..."

  if ! curl --fail -s -H "Authorization: Bearer $token" "https://${hostname}${path}admin/terraform-versions?page\[number\]=$page&page\[size\]=100" > "$diagid/versions-$page.json"; then
    error "failed to fetch terraform versions. Use terraform login <hostname> with a site admin user and ensure hostname is accessible."
  fi

  page=$(jq '.meta.pagination."next-page"' -r "$diagid/versions-$page.json")
done
# ...and concatenate together
jq -n 'reduce inputs.data as $d (.; . + $d)' "$diagid"/*.json > "$diagid/versions.json"

# Archive source diag folder
info "Creating tar archive \"$diagid.tar.gz\"..."
tar -czf "$diagid.tar.gz" "$diagid"

# Remove source diag folder
info "Cleaning up..."
rm -rf "$diagid"
