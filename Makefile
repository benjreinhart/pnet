default: build

BIN = node_modules/.bin
SRCDIR = src
LIBDIR = lib

SRC = $(shell find "$(SRCDIR)" -name "*.coffee" -type f | sort)
LIB = $(SRC:$(SRCDIR)/%.coffee=$(LIBDIR)/%.js)

COFFEE = $(BIN)/coffee --js

all: build
build: $(LIB)

$(LIBDIR)/%.js: $(SRCDIR)/%.coffee
	@mkdir -p "$(@D)"
	$(COFFEE) <"$<" >"$@"

tag:
	git tag v`./node_modules/.bin/coffee -e --cli "console.log JSON.parse(require('fs').readFileSync('package.json')).version"`
