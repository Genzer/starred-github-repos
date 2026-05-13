#!/usr/bin/env bash
set -e -u -o pipefail

main() {

  if [[ "${DEBUG:-FALSE}" == "TRUE" ]]; then
    set -x
  fi

  local -r github_handle="$1"

  # Print CSV Header
  echo '"repo","starred_at","url","description"'

  # Using GitHub CLI for better pagination.
  #
  # [1]: I found out from
  # https://gist.github.com/jasonrudolph/5abee158b42b99a3990a that using the
  # correct MIME type of vnd.github.v3.star+json result with the field
  # starred_at.`
  #
  # [2]: By default, GitHub API implicitly responds in reverse chronologically
  # order, but I don't want to rely on this undocumented behavior. Here I do an
  # explicit sort.
  gh api \
    -X GET "/users/$github_handle/starred" -q 'per-page=1000' \
    --paginate `# [1]` \
    --header 'Accept: application/vnd.github.v3.star+json' \
    --jq '. | sort_by(.starred_at)
            | reverse 
            | .[] 
            | { 
                  full_name: .repo.full_name,
                  starred_at: .starred_at,
                  description: .repo.description,
                  html_url: .repo.html_url
              }
           | [.full_name, .starred_at, .html_url, .description] | @csv' 

}

main "$@"
