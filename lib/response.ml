open Core
open Kernel.Mealy
open Async

type message = Store.events
type events = [ `Responded ]
type state = Writer.t

let handler state msg =
  match msg with
  | `SetSuccess (k, v) ->
    Log.Global.info "[%s] set to [%s]." k v;
    `Responded, state
  | `GetFail v ->
    Log.Global.info "Could not find [%s]." v;
    `Responded, state
  | `GetSuccess (k, v) ->
    Writer.write state (Format.sprintf "[%s] -> [%s].\n" k v);
    `Responded, state
;;

let machine : (message, events, state) Kernel.Mealy.t =
  { initial = force Writer.stdout; action = handler }
;;
