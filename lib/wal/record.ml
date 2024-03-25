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

let serialize {crc; size; logid; payload} =
  let crc' = UInt32.to_int crc in
  let size' = UInt16.to_int size in
  let logid' = UInt32.to_int logid in
  Format.sprintf "%d%d%d%s" crc' size' logid' (Bytes.to_string payload)
