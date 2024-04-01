.phony: doc

doc:
	@dune build @doc
	@yes | cp -rf theme/* _build/default/_doc/_html/odoc.support

doc-commit:
	@dune build @doc
	@rm -rf doc-caliburn/*
	@cp -rf _build/default/_doc/_html/* doc-caliburn
	@yes | cp -rf theme/* doc-caliburn/odoc.support