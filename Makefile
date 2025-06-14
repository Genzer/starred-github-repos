# vim: set syntax=Makefile
# Makefile Configuration
ifeq ($(origin .RECIPEPREFIX), undefined)
  $(error This Make does not support .RECIPEPREFIX. Please use GNU Make 4.0 or later)
endif
.RECIPEPREFIX = >
SHELL := bash
.ONESHELL:
.SHELLFLAGS := -eu -o pipefail -c
.DEFAULT_GOAL=help

#----------
# TARGETS
#----------

.PHONY: all
all: Genzer.starred.*

Genzer.starred.jsonl:
>	@bash scripts/fetch_stars.sh 'Genzer' >$@

Genzer.starred.csv: Genzer.starred.jsonl
>	@echo '"repo" | "url" | "description" |' >|$@
>	@cat $< | jq -r '[.full_name,.html_url,.description] | @csv' >>$@

Genzer.starred.md: Genzer.starred.jsonl
>	@echo '| repo | url | description |' >|$@
>	@echo '|-|-|-|' >>$@
>	@cat $< | jq -r '"| \(.full_name) | <\(.html_url)> | \(.description) |"' >>$@

Genzer.starred.adoc: Genzer.starred.jsonl
>	@echo '[%header,cols="3"]' >|$@
>	@echo '|===' >>$@
> @echo '| repo ' >>$@
> @echo '| url ' >>$@
> @echo '| description ' >>$@
> @echo '' >>$@

>	@cat $< | jq -r '"\n| \(.full_name) \n| <\(.html_url)> \n| \(.description)"' >>$@
> @echo '|===' >>$@


#----------
# HELP 
#----------
help:         ## Show this help.
> @awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m (default: help)\n\nTargets:\n"} /^[a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-12s\033[0m %s\n", $$1, $$2 }' $(MAKEFILE_LIST)
