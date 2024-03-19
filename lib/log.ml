open Core
open Mealy

type message = Store.events

type events =
  [ `Persisted
  | `NotNeeded
  ]

type state =
  { index : int
  ; chan : Out_channel.t
  }

let entry index key value =
  let a x = Sexp.Atom x
  and l x = Sexp.List x in
  l
    [ l [ a "index"; Int.sexp_of_t index ]
    ; l [ a "key"; String.sexp_of_t key ]
    ; l [ a "data"; String.sexp_of_t value ]
    ]
;;

let append { index; chan } ~key ~value =
  let payload = entry index key value |> Sexp.to_string_mach in
  let () = Out_channel.fprintf chan "%s\n" payload in
  { index = index + 1; chan }
;;

let handler state (msg : message) =
  match msg with
  | `GetFail (_x : string) -> `NotNeeded, state
  | `GetSuccess (_x, _y : string * string) -> `NotNeeded, state
  | `SetSuccess (key, value) ->
    let res = append state ~key ~value in
    Out_channel.flush state.chan;
    `Persisted, res
;;

let create filename =
  let initial = { index = 0; chan = Out_channel.create ~append:true filename } in
  let action = handler in
  { initial; action }
;;
