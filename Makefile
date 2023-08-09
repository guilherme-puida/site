.PHONY: all
all:
	./gen.tcl

.PHONY: deploy
deploy: all
	@git diff --quiet || { echo 'dirty tree, commit first'; exit 1; }
	wrangler pages deploy dist \
		--project-name site \
		--branch main
