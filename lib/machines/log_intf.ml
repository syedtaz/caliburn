open Core

module type Serializable = Signatures.Common.Serializable

module Logmsg = struct
  type ('key, 'value) t =
  [ `Insert of 'key * 'value
  | `Delete of 'key
  ]
[@@deriving bin_io]
end

type ('key, 'value) event =
  | PassedK : 'key Option.t -> ('key, _) event
  | PassedV : 'value Option.t -> (_, 'value) event
  | Delete : 'key * 'value Option.t -> ('key, 'value) event
  | Insert : 'key * 'value * 'value Option.t -> ('key, 'value) event

type ('key, 'value) response =
  | SuccessKey : 'key Option.t -> ('key, _) response
  | SuccessValue : 'value Option.t -> (_, 'value) response
  | Failed : (_, _) response

module type Log = sig
  type key
  type value
  type state

  val machine
    :  string
    -> ((key, value) event, (key, value) response, state) Kernel.Mealy.t
end

module type Interface = sig
  module Make : functor (S : Serializable) ->
    Log with type key = S.key and type value = S.value
end
