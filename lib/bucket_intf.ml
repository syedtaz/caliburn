module type Serializable = Kernel.Common.Serializable
module type Bucket = sig
  open Core

  type key
  type value
  type t
  type error

  val bucket : t

  (** [insert bucket k v] binds [v] to [k] in the bucket and returns
      the previous binding if it was set. *)
  val insert : key -> value -> (value Option.t, error) Result.t

  (** [get bucket k] returns the value of [k] if it was set. *)
  val get : key -> (value Option.t, error) Result.t

  (** [delete bucket k] removes [k] from the bucket and returns the previous
      binding if it was set. *)
  val delete : key -> (value Option.t, error) Result.t

(*
  (** [contains bucket k] returns [true] if the bucket contains the key. *)
  val contains : 'e. t -> key -> (bool, 'e) Result.t

  (** [update_fetch bucket k f] checks if the binding for [k] exists, applies
      [f] to the binding and returns the new value. *)
  val update_fetch
    : 'e. t
    -> key
    -> f:(value Option.t -> value)
    -> (value Option.t, 'e) Result.t

  (** [fetch_update bucket k f] checks if the binding for [k] exists, applies
      [f] to the binding and returns the old value. *)
  val fetch_update
    :  'e. t
    -> key
    -> f:(value Option.t -> value)
    -> (value Option.t, 'e) Result.t

  (** [length bucket] returns the number of elements in the bucket in linear
      time. *)
  val length : t -> int

  (** [is_empty bucket] returns [true] if the bucket has no elements. *)
  val is_empty : t -> bool

  (** [clear bucket] removes all the bindings in the bucket. *)
  val clear : 'e. t -> (unit, 'e) Result.t

  (** [max bucket] returns the largest key-value pair in the bucket. *)
  val max : 'e. t -> ((key * value) Option.t, 'e) Result.t

  (** [min bucket] returns the smallest key-value pair in the bucket. *)
  val min : 'e. t -> ((key * value) Option.t, 'e) Result.t *)
end

module type Interface = sig
  module Make : functor (S : Serializable) -> Bucket with type key = S.key and type value = S.value
end
