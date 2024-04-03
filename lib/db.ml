open Core
include Db_intf

(* : DB with type key = S.key and type value = S.value *)
module Make (S : Serializable) : DB with type key = S.key and type value = S.value =
struct
  type key = S.key
  type value = S.value

  module Store = Store.Make (S)

  type t =
    { fd : Core_unix.File_descr.t
    ; mutable store :
        ((key, value) Store_intf.event, value Store_intf.response) Kernel.Mealy.s
    }

  let open_db path : (t, [> `Cannot_determine ]) result =
    let store = Kernel.Mealy.unfold Store.machine in
    match Sys_unix.file_exists ~follow_symlinks:true path with
    | `Unknown -> Error `Cannot_determine
    | `Yes -> Ok { fd = Core_unix.openfile ~mode:[ O_RDWR ] path; store }
    | `No ->
      let dirname = Filename.dirname path in
      Core_unix.mkdir_p dirname;
      Ok { fd = Core_unix.openfile ~mode:[ O_CREAT; O_RDWR ] path; store }
  ;;

  let ( >>/ ) (db : t) event =
    let res, ns = db.store.action event in
    db.store <- ns;
    Ok res
  ;;

  let get db key = db >>/ `Get key
  let insert db ~key ~value = db >>/ `Insert (key, value)
  let delete db key = db >>/ `Delete key
  let update_fetch db key ~f = db >>/ `UpdateFetch (key, f)
  let fetch_update db key ~f = db >>/ `FetchUpdate (key, f)
end
