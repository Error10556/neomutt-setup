.PHONY: all
all: build/neomutt-setup.sh

build/neomutt-setup.sh: source.sh templates/version templater.sh | build
	./templater.sh source.sh >$@
	chmod +x $@

build:
	mkdir build
