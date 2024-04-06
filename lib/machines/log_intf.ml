open Core

module type Serializable = Signatures.Common.Serializable

type ('key, 'value) event =
  [ `Insert of 'key * 'value Option.t
  | `Delete of 'key * 'value Option.t
  | `PassedK of 'key Option.t
  | `PassedV of 'value Option.t
  ]
[@@deriving bin_io]

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
