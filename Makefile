.PHONY: docs clean

docs:
	jupyter-book build .
	rm -rf docs
	mkdir -p docs
	cp -r _build/html/* docs/
	touch docs/.nojekyll

clean:
	rm -rf _build docs