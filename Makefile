.PHONY: all
all: build/neomutt-setup.sh

build/neomutt-setup.sh: source.sh templates/* \
	build/templates/launcher-escaped.sh templater.sh | build
	./templater.sh source.sh >$@
	chmod +x $@

build/templates/launcher-escaped.sh: build/templates/launcher.sh \
	bash-escaper.sh | build/templates
	./bash-escaper.sh <$< >$@

build/templates/launcher.sh: templates/launcher.sh templates/version.sh \
	templates/colors.sh templates/fn_dialog.sh templater.sh | build/templates
	./templater.sh $< >$@

build/templates: | build
	mkdir build/templates

build:
	mkdir build
