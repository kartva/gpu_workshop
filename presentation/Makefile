TYPST := typst

.PHONY: all
all: example

.PHONY: example
example: example.pdf

%.pdf: %.typ theme.typ
	$(TYPST) compile --font-path ./fonts $<
