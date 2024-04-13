module type Serializable = Signatures.Common.Serializable

module Logmsg = Log_intf.Logmsg

module type Bootstrap = sig
  type key
  type value

  val generate_msgs : string -> [> `Delete of key | `Insert of key * value ] list
end

module type Interface = sig
  module Make : functor (S : Serializable) ->
    Bootstrap with type key = S.key and type value = S.value
end
