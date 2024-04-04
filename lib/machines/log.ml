open Core
include Log_intf

module Serializer (S : Serializable) = struct
  let bin_buffer = Bin_prot.Common.create_buf 2000
  let byte_buffer = Bytes.create 2000

  let write_size key value =
    let ksize = S.bin_size_key key in
    let vsize = S.bin_size_value value in
    let next =
      Bin_prot.Write.bin_write_nat0 bin_buffer (Bin_prot.Nat0.of_int ksize) ~pos:0
    in
    let final =
      Bin_prot.Write.bin_write_nat0 bin_buffer (Bin_prot.Nat0.of_int vsize) ~pos:next
    in
    final
  [@@inline always]
  ;;

  let write_kv_buffer key value =
    let start = write_size key value in
    let next = S.bin_write_key bin_buffer key ~pos:start in
    let final = S.bin_write_value bin_buffer value ~pos:next in
    final
  ;;

  let serialize fd key value =
    let fpos = write_kv_buffer key value in
    Bin_prot.Common.blit_buf_bytes ~src_pos:0 ~len:fpos bin_buffer byte_buffer ~dst_pos:0;
    let written = Core_unix.single_write ~pos:0 ~len:fpos ~buf:byte_buffer fd in
    match Int.equal written fpos with
    | true ->
      Core_unix.fsync fd;
      `Persisted
    | false -> `Failed
  ;;
end

module Make (S : Serializable) : Log with type key = S.key and type value = S.value =
struct
  type key = S.key
  type value = S.value
  type state = { mutable fd : Core_unix.File_descr.t }
  type event' = (key, value) event

  module Serializer = Serializer (S)

  let handler (state : state) (event : event') : response * state =
    match event with
    | `Insert (key, value) -> Serializer.serialize state.fd key value, state
    | `Get _ -> `Passed, state
    | `UpdateFetch _ | `Delete _ | `FetchUpdate _ -> `Persisted, state
  ;;

  let open_or_create path =
    match Sys_unix.file_exists ~follow_symlinks:true path with
    | `Yes -> Core_unix.openfile ~mode:[ O_WRONLY; O_APPEND ] path
    | `Unknown | `No ->
      let dirname = Filename.dirname path in
      Core_unix.mkdir_p dirname;
      Core_unix.openfile ~mode:[ O_CREAT; O_RDWR ] path
  ;;

  let machine (path : string) : (event', response, state) Kernel.Mealy.t =
    { initial = { fd = open_or_create (path ^ ".log") }; action = handler }
  ;;
end
