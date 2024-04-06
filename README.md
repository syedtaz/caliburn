<div align="center">
  <img src="./icon.png" alt="Caliburn logo."/>
  <br />
  <div>
  <br/>
  <a href="https://syedtaz.github.io/doc-caliburn/caliburn/Caliburn/index.html"><img src="https://img.shields.io/badge/doc-online-blue.svg?style=flat-square" alt="documentation"></img></a>
  <img src="https://img.shields.io/github/license/syedtaz/caliburn" alt="license-bsd">
  <img src="https://img.shields.io/github/v/release/syedtaz/caliburn" alt="release">
  </div>
  <a href="https://www.flaticon.com/free-icons/legend" title="legend icons">art by surang from Flaticon</a>
</div>

# Caliburn

Persistent, embedded key-value store in pure OCaml. Work in progress.

Inspired by [rocksdb](https://github.com/facebook/rocksdb) and
[sled](https://github.com/spacejam/sled).


## Installation

You can add a pin to the either the main branch or one of the releases. I plan
to add Caliburn to the OPAM registry once the library is somewhat stable.

```
$ opam pin caliburn https://github.com/syedtaz/caliburn.git#main
```

## Quickstart

First, you need to open or create a database. After that, you can insert,
delete or get key-values at your discretion.

```ocaml
open Caliburn

(* Let's say we want to store a mapping between [id]s and [name]s. *)

(*  A module that represents the type of the key-value pairs we will
    parameterize the database over. *)
module KVType = struct
  type key = int [@@deriving bin_io, hash, sexp, compare]
  type value = string [@@deriving bin_io, hash, sexp, compare]
end

(*  A module for handling [int, string] stores. *)
module Id_db = DB.Make (KVType)

(* Insert a key and check that it's there :) *)
let%expect_test _ =
let db = Id_db.open_db "some/database" in
[%defer Id_db.close db];
let open Result.Let_syntax in
ignore
  (let%bind _ = Id_db.insert db ~key:1912 ~value:"Titanic sinks!" in
    let%bind res = Id_db.get db 1912 in
    (match res with
    | Some v -> Format.printf "we found the value : %s" v
    | None -> Format.print_string "we couldn't find a value?");
    return ());
[%expect {| we found the value : Titanic sinks! |}]
```

----

### References

-  [CMU Database Group](https://www.youtube.com/@CMUDatabaseGroup)
-  [Sled](https://sled.rs)
-  [LSM-based Storage Techniques: A Survey](https://arxiv.org/abs/1812.07527)
-  [Building an Efficient Put-Intensive Key-Value Store with Skip-Tree](https://ieeexplore.ieee.org/document/7569086)
-  [A Practical Concurrent Index for Solid-State Drives](http://db.cs.duke.edu/papers/cikm12-ThonangiBabuYang-concurrent_ssd_index.pdf)