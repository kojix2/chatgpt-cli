CRYSTAL_BIN ?= crystal
SHARDS_BIN ?= shards
PREFIX ?= /usr/local

UNAME_S := $(shell uname -s)

DEFAULT_READLINE := $(if $(filter $(UNAME_S), Linux Darwin),1,0)
DEFAULT_BAT := $(if $(filter $(UNAME_S), Linux Darwin),1,0)

readline ?= $(DEFAULT_READLINE)
bat ?= $(DEFAULT_BAT)
flags ?=

RELEASE_FLAG :=
ifeq ($(release), 1)
	RELEASE_FLAG := --release
endif

.PHONY: build
build: ./bin/chatgpt

./bin/chatgpt:
	CHATGPT_READLINE=$(readline) CHATGPT_BAT=$(bat) $(SHARDS_BIN) build $(RELEASE_FLAG) $(flags)

.PHONY: spec
spec:
	$(CRYSTAL_BIN) spec

.PHONY: lint
lint:
	$(CRYSTAL_BIN) tool format

.PHONY: clean
clean:
	rm -f ./bin/chatgpt ./bin/chatgpt.dwarf

.PHONY: install
install: ./bin/chatgpt
	mkdir -p $(PREFIX)/bin
	cp ./bin/chatgpt $(PREFIX)/bin

.PHONY: test
test: spec lint

.PHONY: help
help:
	@echo "Usage: make [target] [readline=1] [bat=1] [release=1]"
	@echo "Targets:"
	@echo "  build    Build the project"
	@echo "  spec     Run the project's specs"
	@echo "  lint     Run the linter"
	@echo "  clean    Remove build artifacts"
	@echo "  install  Install the project"
	@echo "  test     Run all tests"
