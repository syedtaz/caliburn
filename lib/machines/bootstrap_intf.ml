module type Serializable = Signatures.Common.Serializable

module Logmsg = Log_intf.Logmsg

type event = unit
type ('key, 'value) response = ('key, 'value) Logmsg.t list

module type Bootstrap = sig
  type key
  type value
  type state

  val machine : string -> (event, (key, value) response, state) Kernel.Mealy.t
end

module type Interface = sig
  module Make : functor (S : Serializable) ->
    Bootstrap with type key = S.key and type value = S.value
end
