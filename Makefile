# Makefile for compiling and installing code-editor.cr

# Variables
BIN = chatgpt
SRC = chatgpt.cr
PREFIX ?= /usr/local/bin

# Targets
all: $(BIN)

$(BIN): $(SRC)
	shards install --production
	crystal build --release $(SRC) -o $(BIN)

clean:
	rm -f $(BIN)

install: $(BIN)
	install -m 0755 $(BIN) $(PREFIX)/$(BIN)

.PHONY: all clean install
