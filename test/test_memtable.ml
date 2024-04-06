open Caliburn
open! Core

module S = struct
  type key = int [@@deriving bin_io, hash, sexp, compare]
  type value = string [@@deriving bin_io, hash, sexp, compare]
end

module Int_DB = Db.Make (S)

let db = Int_DB.open_db "./some/file" |> Stdlib.Result.get_ok

type ret = (string Option.t, Errors.t) Result.t

let%expect_test _ =
  let open Result.Let_syntax in
  ignore
    (let%bind res = Int_DB.get db 10 in
     return
       (Option.value_map
          res
          ~default:(Format.print_string "could not find value")
          ~f:(fun x -> Format.printf "value : %s" x)));
  [%expect {| could not find value |}]
;;

let%expect_test _ =
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
;;
