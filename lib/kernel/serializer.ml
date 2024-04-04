open Core

module Make (S : Signatures.Common.Serializable) = struct
  open Bin_prot

  let position = ref 0
  let buffer = Common.create_buf 2000
  let str_buffer = Bytes.create 2000

  let serialize_key ~key writer =
    let length = S.bin_size_key key in
    let () =
      match !position - length > 34 with
      | false -> position := 0
      | true -> ()
    in
    let start = !position in
    position := S.bin_write_key buffer ~pos:!position key;
    let len = !position - start in
    Common.blit_buf_bytes buffer ~src_pos:start str_buffer ~dst_pos:0 ~len;
    Out_channel.output_binary_int writer (Crc.crc32_no_copy buffer start length);
    Out_channel.output_binary_int writer len;
    Out_channel.output writer ~buf:str_buffer ~pos:0 ~len;
    Out_channel.flush writer
  ;;
end
