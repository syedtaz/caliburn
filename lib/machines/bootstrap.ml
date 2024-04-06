open Core
include Bootstrap_intf

(* : Bootstrap with type key = S.key and type value = S.value*)
module Make (S : Serializable) = struct
  type key = S.key
  type value = S.value
  type state = { fd : Core_unix.File_descr.t }

  module Deserializer = struct
    let pos_ref = ref 0

    let load fd =
      let stat = Core_unix.stat (Core_unix.File_descr.to_string fd) in
      let nbytes = stat.st_size in
      (* Unsafe *)
      Bigstring_unix.map_file ~shared:false fd (Int64.to_int_exn nbytes)
    ;;

    let read fd =
      let buf = load fd in
      let rec aux prev acc =
        let res = Logmsg.bin_read_t S.bin_read_key S.bin_read_value buf ~pos_ref in
        match prev = !pos_ref with
        | true -> List.rev acc
        | false -> aux !pos_ref (res :: acc)
      in
      aux !pos_ref []
    ;;
  end

  let handler (state : state) (_ : event) : (key, value) response * state =
    let res = Deserializer.read state.fd in
    Core_unix.close state.fd;
    res, state
  ;;

  let machine path : (event, (key, value) response, state) Kernel.Mealy.t =
    { initial = { fd = Kernel.Files.open_or_create (path ^ ".log") }; action = handler }
  ;;
end
