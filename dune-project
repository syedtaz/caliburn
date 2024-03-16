(lang dune 3.12)

(name caliburn)

(generate_opam_files true)

(source
 (github syedtaz/caliburn))

(authors "Tazmilur Saad")

(maintainers "Tazmilur Saad")

(license MIT)

(package
 (name caliburn)
 (synopsis "Distributed key-value cache written in pure OCaml.")
 (description "Distributed key-value cache written in pure OCaml.")
 (depends ocaml dune)
 (tags
  ("kv" "cache")))