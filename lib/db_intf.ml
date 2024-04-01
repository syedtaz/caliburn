module type Serializable = Kernel.Common.Serializable

module type DB = sig
(** A [DB] is the module used to interact with a data store that is
    parameterized over a module that represents a [Serializable] type.
    Given such a module,a data store can created or loaded using [open] and
    you can update the store using the various functions such as [insert],
    [delete], etc.

    You must pass in a module that contains functions that show how to convert
    between the byte level representations of the types of the keys and values.
    A simply way to derive them is to use [@@deriving bin_io]
  *)

  type key
  type value
  type t

  (** [open_db] loads the database stored at the path into memory if it exists
      or creates a database at that directory and initializes a fresh instance.*)
  val open_db : string -> t
end

module type Interface = sig
  module Make : functor (S : Serializable) -> DB with type key = S.key and type value = S.value
end