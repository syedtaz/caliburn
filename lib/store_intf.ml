module type Serializable = Kernel.Common.Serializable

type ('key, 'value) event =
  [ `Insert of 'key * 'value
  | `Get of 'key
  ]

type 'value response = ('value Option.t, Errors.t) Result.t

module type Store = sig
  type key
  type value
  type state

  val machine : ((key, value) event, value response, state) Kernel.Mealy.t
end

module type Interface = sig
  module Make : functor (S : Serializable) ->
    Store with type key = S.key and type value = S.value
end
