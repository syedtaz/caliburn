open Core
include Db_intf

module Make (S : Serializable) : DB with type key = S.key and type value = S.value =
struct
  type key = S.key
  type value = S.value

  module Memtable = Machine.Memtable.Make (S)
  module Log = Machine.Log.Make (S)

  type t =
    { fd : Core_unix.File_descr.t
    ; mutable store :
        ( (key, value) Machine.Memtable_intf.event
          , value Machine.Memtable_intf.response )
          Kernel.Mealy.s
    ; mutable log :
        ((key, value) Machine.Log_intf.event, Machine.Log_intf.response) Kernel.Mealy.s
    }

  let open_db path : (t, [> `Cannot_determine ]) result =
    let store = Kernel.Mealy.unfold Memtable.machine in
    let log = Kernel.Mealy.unfold (Log.machine path) in
    match Sys_unix.file_exists ~follow_symlinks:true path with
    | `Unknown -> Error `Cannot_determine
    | `Yes -> Ok { fd = Core_unix.openfile ~mode:[ O_RDWR ] path; store; log }
    | `No ->
      let dirname = Filename.dirname path in
      Core_unix.mkdir_p dirname;
      Ok { fd = Core_unix.openfile ~mode:[ O_CREAT; O_RDWR ] path; store; log }
  ;;

  let close_db (db : t) : unit = Core_unix.close db.fd

  let ( >>/ ) (db : t) event =
    let res, ns = db.store.action event in
    let _, ns' = db.log.action event in
    db.store <- ns;
    db.log <- ns';
    Ok res
  ;;

  let get db key = db >>/ `Get key
  let insert db ~key ~value = db >>/ `Insert (key, value)
  let delete db key = db >>/ `Delete key
  let update_fetch db key ~f = db >>/ `UpdateFetch (key, f)
  let fetch_update db key ~f = db >>/ `FetchUpdate (key, f)
end
