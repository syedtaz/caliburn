open Caliburn
open Core

module X0 = struct
  open Core

  type key = int [@@deriving bin_io]
  type value = string [@@deriving bin_io]
end

module Int_DB = Db.Make (X0)

let%expect_test _ =
  let path = "some/file" in
  match Int_DB.open_db path with
  | Ok v ->
    Int_DB.close_db v;
    Format.print_string "ok"
  | Error exn -> Format.print_string (Int_DB.sexp_of_errors exn |> Sexp.to_string_hum);
  [%expect {| ok |}]
;;
