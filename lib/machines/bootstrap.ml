open Core
include Bootstrap_intf

(* *)
module Make (S : Serializable) :
  Bootstrap with type key = S.key and type value = S.value = struct
  type key = S.key
  type value = S.value

  module Deserializer = struct
    let pos_ref = ref 0

    let load path fd =
      let stat = Core_unix.stat path in
      let nbytes = stat.st_size in
      (* Unsafe *)
      Bigstring_unix.map_file ~shared:false fd (Int64.to_int_exn nbytes)
    ;;

    let read path fd =
      let buf = load path fd in
      let rec aux prev acc =
        let res = Logmsg.bin_read_t S.bin_read_key S.bin_read_value buf ~pos_ref in
        match prev = !pos_ref with
        | true -> List.rev acc
        | false -> aux !pos_ref (res :: acc)
      in
      aux !pos_ref []
    ;;
  end

  let generate_msgs path : [> `Delete of key | `Insert of key * value ] list =
    let open Core_unix in
    match Sys_unix.file_exists ~follow_symlinks:true path with
    | `No | `Unknown -> []
    | `Yes ->
      let fd = openfile ~mode:[ O_RDONLY ] path in
      let res = Deserializer.read path fd in
      close fd;
      res
  ;;
end
