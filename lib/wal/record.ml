open Core
open Unsigned

type t =
  { crc : int
  ; size : UInt16.t (* ; label : UInt8.t *)
  ; logid : UInt32.t
  ; payload : Bytes.t
  }

let of_bytes (id : int) ~(payload : Bytes.t) =
  let crc = Crc.crc32 payload in
  let size = Bytes.length payload |> UInt16.of_int in
  let logid = UInt32.of_int id in
  { crc; size; logid; payload }
;;

let serialize { crc; size; logid; payload } =
  let crc' = crc in
  let size' = UInt16.to_int size in
  let logid' = UInt32.to_int logid in
  Format.sprintf "%d%d%d%s" crc' size' logid' (Bytes.to_string payload)
;;

module W (S : Binable.Minimal.S) = struct
  open Bin_prot

  let position = ref 0
  let buffer = Common.create_buf 2000
  let crc_buffer = Bytes.create 2000

  let serialize obj =
    let length = S.bin_size_t obj in
    let () =
      match !position - length > 34 with
      | false -> position := 0
      | true -> ()
    in
    let start = !position in
    position := S.bin_write_t buffer ~pos:!position obj;
    let () =
      Common.blit_buf_bytes
        buffer
        ~src_pos:start
        crc_buffer
        ~dst_pos:0
        ~len:(!position - start)
    in
    ()
  ;;
end
