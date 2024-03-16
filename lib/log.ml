open Core
open Utils

type message =
  [ `Append of string * Bytes.t
  | `AppendMany of (string * Bytes.t) list
  ]

type state =
  { index : int
  ; chan : Out_channel.t
  }

let create filename =
  { index = 0; chan = Out_channel.create ~append:true filename}

let entry index key value =
  let a x = Sexp.Atom x
  and l x = Sexp.List x in
  l
    [ l [ a "index"; Int.sexp_of_t index ]
    ; l [ a "key"; String.sexp_of_t key ]
    ; l [ a "data"; Bytes.sexp_of_t value ]
    ]
;;

let append { index; chan } ~key ~value =
  let payload = entry index key value |> Sexp.to_string_mach in
  let () = Out_channel.fprintf chan "%s\n" payload in
  { index = index + 1; chan }
;;

let append_many init_state ~pairs =
  List.fold pairs ~init:init_state ~f:(fun state (key, value) -> append state ~key ~value)
;;

let handler state ~msg = match msg with
  | `Append (key, value) -> append state ~key ~value <* flush state.chan
  | `AppendMany pairs -> append_many state ~pairs <* flush state.chan
;;