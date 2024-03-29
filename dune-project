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
 (synopsis "Persistent, embedded key-value store written in pure OCaml.")
 (description "Persistent, embedded key-value store written in pure OCaml.")
 (depends ocaml dune)
 (tags
  ("kv" "cache")))