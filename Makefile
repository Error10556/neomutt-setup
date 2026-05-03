.PHONY: all
all: build/neomutt-setup.sh

build/neomutt-setup.sh: source.sh templates/* \
	build/templates/launcher-escaped.sh templater.sh | build
	./templater.sh source.sh >$@
	chmod +x $@

build/templates/launcher-escaped.sh: templates/launcher.sh templater.sh \
	bash-escaper.sh | build/templates
	./bash-escaper.sh <$< >$@

build/templates: | build
	mkdir build/templates

build:
	mkdir build
