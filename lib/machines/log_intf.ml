module type Serializable = Signatures.Common.Serializable

type ('key, 'value) event =
  [ `Insert of 'key * 'value
  | `Get of 'key
  | `Delete of 'key
  | `UpdateFetch of 'key * ('value Option.t -> 'value)
  | `FetchUpdate of 'key * ('value Option.t -> 'value)
  ]

type response =
  [ `Persisted
  | `Failed
  | `Passed
  ]

module type Log = sig
  type key
  type value
  type state

  val machine : string -> ((key, value) event, response, state) Kernel.Mealy.t
end

module type Interface = sig
  module Make : functor (S : Serializable) ->
    Log with type key = S.key and type value = S.value
end
