CRYSTAL_BIN ?= crystal
SHARDS_BIN ?= shards
PREFIX ?= /usr/local
SHARD_BIN ?= ../../bin
CRFLAGS ?= -Dpreview_mt

UNAME_S := $(shell uname -s)

.PHONY: build
build:
ifeq ($(UNAME_S),Linux)
build:
	CHATGPT_READLINE=1 CHATGPT_URL=1 CHATGPT_BAT=1 $(SHARDS_BIN) build $(CRFLAGS)
endif
ifeq ($(UNAME_S),Darwin)   # Darwin is for MacOS
build:
	CHATGPT_READLINE=1 CHATGPT_URL=1 CHATGPT_BAT=1 $(SHARDS_BIN) build $(CRFLAGS)
endif
ifeq ($(UNAME_S),Windows)
build:
	CHATGPT_READLINE=0 CHATGPT_URL=0 CHATGPT_BAT=0 $(SHARDS_BIN) build $(CRFLAGS)
endif

.PHONY: spec
spec:
	$(CRYSTAL_BIN) spec

.PHONY: lint
lint: build
	$(CRYSTAL_BIN) tool format --check

.PHONY: clean
clean:
	rm -f ./bin/chatgpt ./bin/chatgpt.dwarf

.PHONY: install
install: build
	mkdir -p $(PREFIX)/bin
	cp ./bin/chatgpt $(PREFIX)/bin

.PHONY: bin
bin: build
	mkdir -p $(SHARD_BIN)
	cp ./bin/chatgpt $(SHARD_BIN)

.PHONY: test
test: spec lint