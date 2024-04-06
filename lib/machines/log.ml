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

    let byte_buffer = Bytes.create 2000
    let writer = Logmsg.bin_writer_t S.bin_writer_key S.bin_writer_value

    let persist fd (e : ('key, 'value) Logmsg.t) =
      let buf = Utils.bin_dump ~header:true writer e in
      let len = Common.buf_len buf in
      Common.blit_buf_bytes ~src_pos:0 buf ~dst_pos:0 byte_buffer ~len;
      let written = Core_unix.single_write ~pos:0 ~len ~buf:byte_buffer fd in
      written = len
    ;;

    let write fd (e : event') : (S.key, S.value) response =
      match e with
      | PassedK x -> SuccessKey x
      | PassedV x -> SuccessValue x
      | Delete (k, ret) ->
        (match persist fd (`Delete k) with
         | true -> SuccessValue ret
         | false -> Failed)
      | Insert (k, v, ret) ->
        (match persist fd (`Insert (k, v)) with
         | true -> SuccessValue ret
         | false -> Failed)
    ;;
  end

  let handler (state : state) (event : event') : (key, value) response * state =
    Serializer.write state.fd event, state
  ;;

  let machine (path : string) : (event', (key, value) response, state) Kernel.Mealy.t =
    { initial = { fd = Kernel.Files.open_or_create (path ^ ".log") }; action = handler }
  ;;
end
