## Vault RISKS Makefile ##

SHELL=/bin/bash
VERSION = $(shell git describe --abbrev=0 --tags --always)

# default produces a single CLI for development purposes
default:
	# Remove all trailing spaces from src code.
	sed -i 's/[ \t]*$$//' **/*.sh

	# First generate the risk script from our source
	bashly generate

	# Remove set -e from the generated script
	# since we handle our errors ourselves
	sed -i 's/set -e//g' risks

	# Add call after initialize but before run to setup log
	sed -i '/parse_requirements "$${/a \ \ _init_log_file' risks
	
# release is used for every new version of the tool
release:
	# Update the version line string
	sed -i 's#^.*\bversion\b.*$$#version: $(VERSION)#' src/bashly.yml
	
	# Change settings from dev to prod
	# (strips a bit of code from the final script)
	sed -i 's#^.*\benv\b.*$$#env: production#' settings.yml
	
	# Remove all trailing spaces from src code.
	sed -i 's/[ \t]*$$//' **/*.sh

	# First generate the risk script from our source
	bashly generate

	# Remove set -e from the generated script
	# since we handle our errors ourselves
	sed -i 's/set -e//g' risks

	# Add call after initialize but before run to setup log
	sed -i '/parse_requirements "$${/a \ \ _init_log_file' risks

	# And reset the settings from prod to dev
	sed -i 's#^.*\benv\b.*$$#env: development#' settings.yml

	# Signatures
	qubes-gpg-client-wrapper --detach-sign risks > risks.gpg
	sha256sum risks > risks.sha

publish:
	# Run the script using the Github CLI to publish
	# a new release, prompting user for version tag
	# and optionally some notes.
	@bash scripts/release
