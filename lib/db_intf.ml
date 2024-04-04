open Core

module type Serializable = Signatures.Common.Serializable

module type DB = sig
  (** A [DB] is the module used to interact with a data store that is
      parameterized over a module that represents a [Serializable] type.
      Given such a module, a data store can created or loaded using [open] and
      you can update the store using the various functions such as [insert],
      [delete], etc.

      You must pass in a module that contains functions that show how to convert
      between the byte level representations of the types of the keys and values.
      A simply way to derive them is to use [@@deriving bin_io] *)

  type key
  type value
  type t

  (** [open_db] loads the database stored at the path into memory if it exists
      or creates a database at that directory and initializes a fresh instance.*)
  val open_db : string -> (t, Errors.t) Result.t

  (** [get db k] returns the value of [k] if it was set and the updated handler
      to the database. *)
  val get : t -> key -> (value Option.t, Errors.t) Result.t

  (** [insert db k v] binds [v] to [k] in the database and returns
      the previous binding if it was set alongside the updated handler
      to the database. *)
  val insert
    :  t
    -> key:key
    -> value:value
    -> (value Option.t, Errors.t) Result.t

  (** [delete db k] removes [k] from the database and returns the previous
      binding if it was set alongside the updated handler to the database. *)
  val delete : t -> key -> (value Option.t, Errors.t) Result.t

  (** [update_fetch bucket k f] checks if the binding for [k] exists, applies
      [f] to the binding and returns the new value. *)
  val update_fetch
    :  t
    -> key
    -> f:(value Option.t -> value)
    -> (value Option.t, Errors.t) Result.t

  (** [fetch_update bucket k f] checks if the binding for [k] exists, applies
      [f] to the binding and returns the old value. *)
  val fetch_update
    :  t
    -> key
    -> f:(value Option.t -> value)
    -> (value Option.t, Errors.t) Result.t
end

module type Interface = sig
  module Make : functor (S : Serializable) ->
    DB with type key = S.key and type value = S.value
end
