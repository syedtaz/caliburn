module type Serializable = Signatures.Common.Serializable

type ('key, 'value) event =
  [ `Insert of 'key * 'value
  | `Get of 'key
  | `Delete of 'key
  | `UpdateFetch of 'key * ('value Option.t -> 'value)
  | `FetchUpdate of 'key * ('value Option.t -> 'value)
  ]

type ('key, 'value) response = ('key, 'value) Log_intf.event

module type Memtable = sig
  type key
  type value
  type state

  val machine : ((key, value) event, (key, value) response, state) Kernel.Mealy.t
end

module type Interface = sig
  module Make : functor (S : Serializable) ->
    Memtable with type key = S.key and type value = S.value
end
