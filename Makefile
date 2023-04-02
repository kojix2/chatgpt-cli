.PHONY: build clean install uninstall test run

PREFIX ?= /usr/local
CRYSTAL_BIN ?= crystal
CRYSTAL_OPTS ?= --release
BINARY_PATH ?= ./bin/chatgpt
SUDO_USER := $(shell ([ "`whoami`" != root ] && echo `whoami`) || ([ -n "$(SUDO_USER)" ] && echo "$(SUDO_USER)") || echo $(USER))
USER_HOME := $(shell eval echo "~$(SUDO_USER)")

build: $(BINARY_PATH)

$(BINARY_PATH): install_dependencies
	shards build $(CRYSTAL_OPTS)

install_dependencies:
	shards install

clean:
	rm -f $(BINARY_PATH)

install: build install-bin

install-bin:
	mkdir -p $(PREFIX)/bin
	cp -f $(BINARY_PATH) $(PREFIX)/bin

uninstall:
	rm $(PREFIX)/bin/chatgpt
	rm -rf $(USER_HOME)/.config/chatgpt-cli
	rm -f $(USER_HOME)/.chatgpt_history

test:
	$(CRYSTAL_BIN) spec

run: build
	$(BINARY_PATH)

