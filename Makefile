.phony: doc

doc:
	@dune build @doc
	@yes | cp -rf theme/* _build/default/_doc/_html/odoc.support