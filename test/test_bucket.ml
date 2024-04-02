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
  let res, _ = Int_DB.get db 10 in
  match res with
  | Ok v ->
    Option.value_map v ~default:(Format.print_string "could not find value") ~f:(fun x ->
      Format.printf "value : %s" x)
  | Error _ ->
    Format.printf "Error occurred.";
  [%expect {| could not find value |}]
;;

let%expect_test _ =
  let res, db' = Int_DB.insert db ~key:1912 ~value:"Titanic sinks!" in
  match res with
  | Ok _ ->
    let res', _ = Int_DB.get db' 1912 in
    (match res' with
     | Ok (Some v) -> Format.printf "we found the value : %s" v
     | Ok None -> Format.print_string "we couldn't find a value?"
     | Error _ -> Format.printf "could not get!")
  | Error _ -> Format.printf "could not insert!";
  [%expect {| we found the value : Titanic sinks! |}]
;;

(* let%expect_test _ =
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
   [%expect {| twenty |}] *)
