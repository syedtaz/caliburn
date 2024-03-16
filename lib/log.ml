open Core

type state =
  { index : int
  ; fd : Core_unix.File_descr.t
  }

type input =
  | Entry of Bytes.t
  | Entries of Bytes.t list

type entry =
  { index : int
  ; data : Bytes.t
  }
[@@deriving sexp]

let init (filename : string) : state =
  let open Core_unix in
  { index = 0; fd = openfile ~mode:[O_WRONLY; O_APPEND; O_CREAT ] filename }
;;

let entry_of_data index data = index + 1, { index; data }

let entries_of_data (start : int) (data_list : Bytes.t list) =
  let final, result =
    List.fold data_list ~init:(start, []) ~f:(fun (index, acc) x ->
      let next, entry = entry_of_data index x in
      next, entry :: acc)
  in
  final, List.rev result
;;

(* TODO! Add stuff if write fails. *)
let apply state input : state =
  let { index; fd } = state in
  match input with
  | Entry v ->
    let next, entry = entry_of_data index v in
    let payload = sexp_of_entry entry |> Sexp.to_string_hum |> Bytes.of_string in
    let _ = Core_unix.single_write fd ~buf:payload in
    { index = next; fd }
  | Entries vs ->
    let final, entries = entries_of_data index vs in
    let payload =
      List.fold entries ~init:[] ~f:(fun acc x ->
        (sexp_of_entry x |> Bytes.t_of_sexp) :: acc)
    in
    let () =
      List.iter payload ~f:(fun x ->
        let _ = Core_unix.single_write fd ~buf:x in
        ())
    in
    { index = final; fd }
;;
