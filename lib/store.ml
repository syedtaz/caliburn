open Core
open Mealy

type message =
  [ `Set of string * Bytes.t
  | `Get of string
  ]

type events =
  [ `SetSuccess
  | `GetSuccess of string * string
  | `GetFail of string
  ]

type state = (string, Bytes.t, String.comparator_witness) Map.t

let empty : state = Map.empty (module String)

let get (state : state) ~key =
  match Map.find state key with
  | Some v -> `GetSuccess (key, Bytes.to_string v), state
  | None -> `GetFail key, state
;;

let set (state : state) ~key ~data =
  match Map.add state ~key ~data with
  | `Ok state' -> `SetSuccess, state'
  | `Duplicate -> `SetSuccess, state
;;

let handler state msg =
  match msg with
  | `Get key -> get state ~key
  | `Set (key, data) -> set state ~key ~data
;;

let machine : (message, events) mealy = unfold { initial = empty; action = handler }
