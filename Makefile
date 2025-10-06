.DEFAULT_GOAL := help
SHELL := bash

version := 0.0.1

.PHONY: help
help:  ## Print this help message.
	@grep -h '\s##\s' $(MAKEFILE_LIST) \
	| awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}' \
	| sort -k1

.PHONY: poetry
POETRY_USE_PYTHON ?=
poetry: require-no-venv-or-project-venv install-poetry poetry.lock ## Create or update a Poetry-based development environment.
	@$(call i, Installing project plus its run time and development requirements...)
	[ -z "$(POETRY_USE_PYTHON)" ] || poetry env use "$(POETRY_USE_PYTHON)"
	poetry install
	@$(call i, Poetry setup and installation complete. Run 'poetry shell' or '. .venv/bin/activate' to activate.)

.PHONY: require-no-venv-or-project-venv
# Require no active conda env. If a virtualenv is active, make sure it belongs to the current project.
require-no-venv-or-project-venv:
	@if [ -n "$(CONDA_SHLVL)" ] && [ "$(CONDA_SHLVL)" -gt "0" ]; then \
		$(call e, A conda environment is currently active. Deactivate before using poetry.); \
		exit 1; \
	elif [ "$$(python3 -c 'import sys; print(sys.prefix == sys.base_prefix)')" = "False" ] \
		&& [ ! "$$(which python)" = "$$(poetry env info --executable)" ]; then \
		$(call e, A virtual environment which does not belong to the current project is active. Deactivate before using poetry.); \
		exit 1; \
	fi

.PHONY: install-poetry
install-poetry: ## Install poetry if not already present.
	@set -e; \
	if command -v poetry > /dev/null; then \
		exit 0; \
	fi; \
	$(call i, Installing Poetry...); \
	if command -v brew > /dev/null; then \
		brew update && brew install poetry; \
	else \
		curl -sSL https://install.python-poetry.org | python3 -; \
	fi
	poetry --version

poetry.lock: pyproject.toml poetry.toml ## Create or update the lock file.
	@$(call i, Updating poetry.lock file...)
	poetry check --lock || poetry lock

.PHONY: poetry.toml
POETRY_ALWAYS_COPY ?= false
poetry.toml:  ## Create or update local Poetry configuration
	@$(call i, Configuring poetry...)
	[ -f poetry.toml ] || touch poetry.toml
	grep 'virtualenvs.create' < poetry.toml || poetry config --local virtualenvs.create true
	grep 'virtualenvs.in-project' < poetry.toml || poetry config --local virtualenvs.in-project true
	grep 'virtualenvs.options.always-copy = true' < poetry.toml \
		|| poetry config --local virtualenvs.options.always-copy $(POETRY_ALWAYS_COPY)