open Core
open Unsigned

type t =
  { crc : UInt32.t
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
