#!/usr/bin/env bash
set -e -u -o pipefail

main() {
  local -r github_handle="$1"
  local -r github_url="https://api.github.com/users/$github_handle/starred?per_page=1000"

  # Print CSV Header
  echo '"repo","url","description"'

  # Print rows
  local page=1
  while curl -s "$github_url&page=${page}" \
    | jq -r -e '.[] | [.full_name, .html_url, .description] | @csv' && [[ ${PIPESTATUS[1]} != 4 ]]; do
    let page++
  done
}

main "$@"
