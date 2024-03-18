open Core

type message =
  [ `Set of string * Bytes.t
  | `Get of string
  ]

type state = (string, Bytes.t, String.comparator_witness) Map.t

let create : state = Map.empty (module String)

let get (state : state) ~key =
  match Map.find state key with
  | Some v ->
    Out_channel.printf "%s" (Bytes.to_string v);
    state
  | None ->
    Out_channel.printf "Could not find %s" key;
    state
;;

let set (state : state) ~key ~data =
  match Map.add state ~key ~data with
  | `Ok state' -> state'
  | `Duplicate -> state
;;

let handler state ~msg =
  match msg with
  | `Get key -> get state ~key
  | `Set (key, data) -> set state ~key ~data
;;