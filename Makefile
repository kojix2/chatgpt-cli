.PHONY: build clean install uninstall test run

PREFIX ?= /usr/local
CRYSTAL_OPTS ?= --release --no-debug
BINARY_PATH ?= ./bin/chatgpt

build: $(BINARY_PATH)

$(BINARY_PATH): install_dependencies
	shards build $(CRYSTAL_OPTS)

install_dependencies:
	shards install

clean:
	rm -f $(BINARY_PATH)

install: build
	mkdir -p $(PREFIX)/bin
	cp $(BINARY_PATH) $(PREFIX)/bin

uninstall:
	rm $(PREFIX)/bin/chatgpt
	rm -rf $(HOME)/.config/chatgpt-cli
	rm $(HOME)/.chatgpt_history

test:
	$(CRYSTAL_BIN) spec

run: build
	$(BINARY_PATH)

