open Caliburn
open! Core

module S = struct
  open Core

  type key = int [@@deriving bin_io, hash, sexp, compare]
  type value = string [@@deriving bin_io, hash, sexp, compare]
end

module Int_DB = Db.Make (S)

type ret = (string option, Db.Make(S).Bucket.error) result

let%expect_test _ =
  let res = Int_DB.Bucket.get 10 in
  match res with
  | Ok v -> Format.print_bool (Option.is_none v)
  | Error _ ->
    Format.printf "Error occurred.";
  [%expect {| true |}]
;;

let%expect_test _ =
  let res = Int_DB.Bucket.insert 10 "ten" in
  match res with
  | Ok v -> Format.print_bool (Option.is_none v)
  | Error _ -> Format.printf "Error occurred.";
  [%expect {| true |}]
;;

let%expect_test _ =
  let (_ : ret) = Int_DB.Bucket.insert 20 "twenty" in
  let res = Int_DB.Bucket.get 20 in
  match res with
  | Ok v ->
    (match v with
     | Some s -> Format.print_string s
     | None -> Format.print_string "Not found")
  | Error _ -> Format.print_string "Error occurred.";
  [%expect {| twenty |}]
;;
