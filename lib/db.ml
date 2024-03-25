open Core

type ('k, 'v) t = Database : ('k, 'v) t

module type Sig = sig
  type key
  type value
end

module Make (X: Sig) = struct
  let open_db (_path : string) : (X.key, X.value) t = Database
end

include Make(struct
  type key = Bytes.t
  type value = Bytes.t
end)
