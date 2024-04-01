open Core
include Db_intf

module Make (S : Serializable) : DB with type key = S.key and type value = S.value =
struct
  type key = S.key
  type value = S.value
  type t = Core_unix.File_descr.t
  type errors = [ `Cannot_determine ]

  module Bucket = Bucket.Make (S)

  let string_of_errors = function
    | `Cannot_determine -> "Cannot determine"

  let open_db path =
    match Sys_unix.file_exists ~follow_symlinks:true path with
    | `Unknown -> Error `Cannot_determine
    | `Yes -> Ok (Core_unix.openfile ~mode:[ O_RDWR ] path)
    | `No ->
      let dirname = Filename.dirname path in
      Core_unix.mkdir_p dirname;
      Ok (Core_unix.openfile ~mode:[ O_CREAT; O_RDWR ] path)
  ;;

  let close_db db = Core_unix.close db
end
