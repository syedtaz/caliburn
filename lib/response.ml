open Core
open Mealy
open Async

type message =
  [ `SetSuccess
  | `GetSuccess of string * string
  | `GetFail of string
  ]

type events = [ `Responded ]
type state = Writer.t

let handler state msg =
  match msg with
  | `SetSuccess ->
    Writer.write state "Successfully set value.\n";
    `Responded, state
  | `GetFail v ->
    Writer.write state (Format.sprintf "Could not find [%s].\n" v);
    `Responded, state
  | `GetSuccess (k, v) ->
    Writer.write state (Format.sprintf "[%s] -> [%s].\n" k v);
    `Responded, state
;;

let machine : (message, events, state) Mealy.t =
  { initial = force Writer.stdout; action = handler }
;;
