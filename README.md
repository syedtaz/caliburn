![Icon of a sword in stone](./icon.png)

<a href="https://www.flaticon.com/free-icons/legend" title="legend icons">Legend icons created by surang - Flaticon</a>

# Caliburn

Key-value store. Work in progress.

Ideal API:

```ocaml
open Caliburn

let%expect_test _ =
  let db = DB.open "some/db" in
  let result = DB.insert ~key:"key" ~value:"value" in
  Format.printf "%s" result
  [%expect {| value |}]
```