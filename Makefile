.DEFAULT_GOAL := help
SHELL := bash

version := 0.0.1

.PHONY: help
help:  ## Print this help message.
	@grep -h '\s##\s' $(MAKEFILE_LIST) \
	| awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}' \
	| sort -k1