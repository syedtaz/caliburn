open Core

type ('k, 'v) t = Database : ('k, 'v) t

module Make (X : Kernel.Common.Sig) = struct
  let open_db (_path : string) : (X.key, X.value) t = Database

  module L = Kernel.Log.Make (X)
end

include Make (struct
    type key = Bytes.t
    type value = Bytes.t

    let byte_of_key x = x
    let byte_of_value x = x
    let value_of_byte x = x
  end)
