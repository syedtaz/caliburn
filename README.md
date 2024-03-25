<div align="center">
  <img src="./icon.png" alt="Caliburn logo."/>
  <br />
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
delete or get key-values at your discretion. If you don't specify the type
of the key-value store, it will default to a database that deals with
pure byte chunks.

Ideal API:

```ocaml
open Caliburn

let db = DB.open "/path/to/database" |> Result.get_ok in
let k = Bytes.of_string "some_key"
and v = Bytes.of_string "some_value" in
match DB.insert db ~key:k ~value:v with
  | Ok _ -> Format.print_string "Success!"
  | Err _ -> Format.print_string "Something went wrong. :<"
```

----

### References

-  [CMU Database Group](https://www.youtube.com/@CMUDatabaseGroup)
-  [Sled](https://sled.rs)