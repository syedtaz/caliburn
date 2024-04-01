module type Serializable = Kernel.Common.Serializable

module type DB = sig
  type key
  type value
  type t

  val open_db : string -> t
end

module type Make = functor (S : Serializable) -> DB with type key = S.key and type value = S.value

module type Interface = sig
  module Make : Make
end