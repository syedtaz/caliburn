open Core
open Mealy
open Async

type message = Store.events
type events = [ `Responded ]
type state = Writer.t

let handler state msg =
  match msg with
  | `SetSuccess (k, v) ->
    Writer.write state (Format.sprintf "[%s] set to [%s].\n" k v);
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
