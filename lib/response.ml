open Core
open Mealy

type message =
  [ `SetSuccess
  | `GetSuccess of string * string
  | `GetFail of string
  ]

type events = [ `Responded ]
type state = Out_channel.t

let handler state msg =
  match msg with
  | `SetSuccess ->
    Out_channel.fprintf state "Successfully set value";
    `Responded, state
  | `GetFail v ->
    Out_channel.fprintf state "Could not find [%s]" v;
    `Responded, state
  | `GetSuccess (k, v) ->
    Out_channel.fprintf state "[%s] -> [%s]" k v;
    `Responded, state
;;

let machine : (message, events) mealy =
  unfold { initial = Out_channel.stdout; action = handler }
;;
