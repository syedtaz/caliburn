(* type ('k, 'v) t = Database : ('k, 'v) t

module Make (X : Kernel.Common.Sig) = struct
  let open_db (_path : string) : (X.key, X.value) t = Database
end *)