open Core
include Log_intf

module Make (S : Serializable) : Log with type key = S.key and type value = S.value =
struct
  type key = S.key
  type value = S.value
  type state = { mutable fd : Core_unix.File_descr.t }
  type event' = (key, value) event

  module Serializer = struct
    open Bin_prot

    let bin_buffer = Common.create_buf 2000
    let byte_buffer = Bytes.create 2000

    let persist fd e =
      let fpos = bin_write_event S.bin_write_key S.bin_write_value bin_buffer e ~pos:0 in
      Bin_prot.Common.blit_buf_bytes
        ~src_pos:0
        ~len:fpos
        bin_buffer
        byte_buffer
        ~dst_pos:0;
      let written = Core_unix.single_write ~pos:0 ~len:fpos ~buf:byte_buffer fd in
      written = fpos
    ;;

    let write fd (e : event') : (S.key, S.value) response =
      match e with
      | `PassedK x -> SuccessKey x
      | `PassedV x -> SuccessValue x
      | `Delete (_, v) ->
        (match v with
         | None -> Failed
         | Some _ ->
           (match persist fd e with
            | true -> SuccessValue v
            | false -> Failed))
      | `Insert (_, x) ->
        (match persist fd e with
         | true -> SuccessValue x
         | false -> Failed)
    ;;
  end

  let handler (state : state) (event : event') : (key, value) response * state =
    Serializer.write state.fd event, state
  ;;

  let open_or_create path =
    match Sys_unix.file_exists ~follow_symlinks:true path with
    | `Yes -> Core_unix.openfile ~mode:[ O_WRONLY; O_APPEND ] path
    | `Unknown | `No ->
      let dirname = Filename.dirname path in
      Core_unix.mkdir_p dirname;
      Core_unix.openfile ~mode:[ O_CREAT; O_RDWR ] path
  ;;

  let machine (path : string) : (event', (key, value) response, state) Kernel.Mealy.t =
    { initial = { fd = open_or_create (path ^ ".log") }; action = handler }
  ;;
end
