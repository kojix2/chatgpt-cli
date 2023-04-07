.PHONY: build clean install uninstall test run docker

PREFIX ?= /usr/local
CRYSTAL_BIN ?= crystal
CRYSTAL_OPTS ?= --release
BINARY_PATH ?= ./bin/chatgpt
SUDO_USER := $(shell ([ "`whoami`" != root ] && echo `whoami`) || ([ -n "$(SUDO_USER)" ] && echo "$(SUDO_USER)") || echo $(USER))
USER_HOME := $(shell eval echo "~$(SUDO_USER)")

build: install_dependencies $(BINARY_PATH)

$(BINARY_PATH):
	shards build $(CRYSTAL_OPTS)

install_dependencies:
	shards install

clean:
	rm -rf ./bin
	rm -rf ./lib
	rm -f ./shard.lock

install: build
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

docker:
	docker run -d --name alpine-chatgpt-cli -v $(PWD):/workspace -w /workspace crystallang/crystal:latest-alpine tail -f /dev/null
	docker exec alpine-chatgpt-cli apk add cmake build-base readline-dev readline-static ncurses-dev ncurses-static ncurses-libs 
	docker exec alpine-chatgpt-cli shards install --without-development --release --static
	docker exec alpine-chatgpt-cli shards build --release --static
	docker exec alpine-chatgpt-cli chmod +x bin/chatgpt
	docker stop alpine-chatgpt-cli
	docker rm alpine-chatgpt-cli
