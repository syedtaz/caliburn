include Db_intf

module Make (S : Serializable) : DB with type key = S.key and type value = S.value = struct
  type key = S.key
  type value = S.value
  type t = Core_unix.File_descr.t

  let open_db path = Core_unix.File_descr.of_string path
end
