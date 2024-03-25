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

let entry key value =
  let payload = Stdlib.Bytes.concat (Bytes.of_string "|") [key; value] in
  Wal.Record.(of_bytes 0 ~payload |> serialize)

let append { index; chan } ~key ~value =
  let payload = entry key value in
  let () = Out_channel.fprintf chan "%s\n" payload in
  { index = index + 1; chan }
;;

let handler state (msg : message) =
  match msg with
  | `GetFail (_x : string) -> `NotNeeded, state
  | `GetSuccess (_x, _y : string * string) -> `NotNeeded, state
  | `SetSuccess (key, value) ->
    let key' = Bytes.of_string key in
    let value' = Bytes.of_string value in
    let res = append state ~key:key' ~value:value' in
    Out_channel.flush state.chan;
    `Persisted, res
;;

let create filename =
  let initial = { index = 0; chan = Out_channel.create ~append:true filename } in
  let action = handler in
  { initial; action }
;;
