open Core

type ('k, 'v) t = Database : ('k, 'v) t

module type Sig = sig
  type key
  type value

  val byte_of_key : key -> Bytes.t
  val byte_of_value : value -> Bytes.t
end

module Make (X : Sig) = struct

  let open_db (_path : string) : (X.key, X.value) t = Database

  module L = Kernel.Log.Make (X)
end

include Make (struct
    type key = Bytes.t
    type value = Bytes.t

    let byte_of_key x = x
    let byte_of_value x = x
  end)
