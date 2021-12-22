.PHONY: clean tests build publish

SHELL := $(shell command -v bash)
DIR := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
export BASH_ENV := $(DIR).envrc
basename := $(shell basename $(DIR))
next := $(shell bin/semver next)
tmpdir := $(shell mktemp -d)

clean:
	@rm -rf $(DIR)build
	@rm -rf $(DIR)/dist
	@rm -rf $(DIR)/*.egg-info
	@bin/bats.sh --clean

tests: clean
	@bin/bats.sh --tests

build: tests
	@git commit -a -m "$(next): build" || true
	@git tag $(next)
	@python3.9 -m build -o $(tmpdir) $(DIR)

publish: build
	@echo $(next)
	@git tag $(next)
	@git push --quiet --tags
	@python3.9 -m build $(DIR)
	@twine upload dist/*
	@sleep 10; python3.9 -m pip install --upgrade $(basename)

install-local-wheel-force: build
	@pip3.9 install --force-reinstall dist/*.whl

install-local-wheel: build
	@pip3.9 install dist/*.whl

verbose: clean
	@bin/bats.sh --verbose
