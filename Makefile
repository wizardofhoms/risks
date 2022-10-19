## Vault RISKS Makefile ##

SHELL=/bin/bash
VERSION = $(shell git describe --abbrev=0 --tags --always)

# default produces a single CLI for development purposes
default:
	# First generate the risk script from our source
	bashly generate
	
	# Remove set -e from the generated script
	# since we handle our errors ourselves
	sed -i 's/set -e//g' risks

# release is used for every new version of the tool
release:
	# Update the version line string
	sed -i 's#^.*\bversion\b.*$$#version: $(VERSION)#' src/bashly.yml
	
	# Change settings from dev to prod
	# (strips a bit of code from the final script)
	sed -i 's#^.*\benv\b.*$$#env: production#' settings.yml
	
	# First generate the risk script from our source
	bashly generate
	
	# Remove set -e from the generated script
	# since we handle our errors ourselves
	sed -i 's/set -e//g' risks
	# And reset the settings from prod to dev
	sed -i 's#^.*\benv\b.*$$#env: development#' settings.yml
