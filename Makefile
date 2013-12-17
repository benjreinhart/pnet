default: build

BIN = node_modules/.bin
SRCDIR = src
LIBDIR = lib

SRC = $(shell find "$(SRCDIR)" -name "*.coffee" -type f | sort)
LIB = $(SRC:$(SRCDIR)/%.coffee=$(LIBDIR)/%.js)

MOCHA = $(BIN)/mocha  --compilers coffee:coffee-script-redux/register -r coffee-script-redux/register
COFFEE = $(BIN)/coffee --js

.PHONY: test

all: build test
build: $(LIB)

$(LIBDIR)/%.js: $(SRCDIR)/%.coffee
	@mkdir -p "$(@D)"
	$(COFFEE) <"$<" >"$@"

test: build
	@$(MOCHA) --reporter spec --recursive --colors

tag:
	git tag v`./node_modules/.bin/coffee -e --cli "console.log JSON.parse(require('fs').readFileSync('package.json')).version"`
