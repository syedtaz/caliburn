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

Let's say we want to store a mapping between integers and strings. So we need a
module that represents the type of the key-value pairs we will
parameterize the database over which we will pass into the Make functor.
This gives us a module for handling id -> name "databases".

```ocaml
open Caliburn

module Id_db = DB.Make (struct
  type key = int [@@deriving bin_io, compare]
  type value = string [@@deriving bin_io, compare]
end)
```

This module can we used to interact with any int-string database. So let's create
one! After that, you can insert, delete or get key-values at your discretion.
You need to remember to close the DB connection once you're done -- otherwise
the file handlers won't be cleaned up.

```ocaml
let%expect_test _ =
  let db = Id_db.open_db "some/database" in
  [%defer Id_db.close db];
  let open Result.Let_syntax in
  let _ =
    let%bind _ = Int_DB.insert db ~key:1912 ~value:"Titanic sinks!" in
    let%bind res = Int_DB.get db 1912 in
    match res with
    | Some v -> return (Format.printf "we found the value : %s" v)
    | None -> return (Format.print_string "we couldn't find a value?")
  in
  ();
[%expect {| we found the value : Titanic sinks! |}]
```

----

### References

-  [CMU Database Group](https://www.youtube.com/@CMUDatabaseGroup)
-  [Sled](https://sled.rs)
-  [LSM-based Storage Techniques: A Survey](https://arxiv.org/abs/1812.07527)
-  [Building an Efficient Put-Intensive Key-Value Store with Skip-Tree](https://ieeexplore.ieee.org/document/7569086)
-  [A Practical Concurrent Index for Solid-State Drives](http://db.cs.duke.edu/papers/cikm12-ThonangiBabuYang-concurrent_ssd_index.pdf)