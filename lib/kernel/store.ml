open Core
open Mealy

type message =
  [ `Set of string * string
  | `Get of string
  ]

type events =
  [ `SetSuccess of string * string
  | `GetSuccess of string * string
  | `GetFail of string
  ]

type state = (string, string, String.comparator_witness) Map.t

let get (state : state) ~key =
  match Map.find state key with
  | Some v -> `GetSuccess (key, v), state
  | None -> `GetFail key, state
;;

let set (state : state) ~key ~data =
  match Map.add state ~key ~data with
  | `Ok state' -> `SetSuccess (key, data), state'
  | `Duplicate -> `SetSuccess (key, data), state
;;

let handler state msg =
  match msg with
  | `Get key -> get state ~key
  | `Set (key, data) -> set state ~key ~data
;;

let machine : (message, events, state) Mealy.t =
  { initial = Map.empty (module String); action = handler }
;;
