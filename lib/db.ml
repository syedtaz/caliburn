open Core
include Db_intf

module Make (S : Serializable)  : DB with type key = S.key and type value = S.value = struct
  type key = S.key
  type value = S.value

  module Store = Store.Make (S)

  type t =
    { fd : Core_unix.File_descr.t
    ; mutable store :
        ((key, value) Store_intf.event, value Store_intf.response) Kernel.Mealy.s
    }

  let open_db path =
    let store = Kernel.Mealy.unfold Store.machine in
    match Sys_unix.file_exists ~follow_symlinks:true path with
    | `Unknown -> Error `Cannot_determine
    | `Yes -> Ok { fd = Core_unix.openfile ~mode:[ O_RDWR ] path; store }
    | `No ->
      let dirname = Filename.dirname path in
      Core_unix.mkdir_p dirname;
      Ok { fd = Core_unix.openfile ~mode:[ O_CREAT; O_RDWR ] path; store }
  ;;

  let close_db db = Core_unix.close db.fd

  let get db key =
     let (res, ns) = db.store.action (`Get key) in
     db.store <- ns;
     res
end
