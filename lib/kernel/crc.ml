open Core

let table =
  let table = Array.create ~len:256 0 in
  let static = 0xEDB88320 in
  for i = 0 to 255 do
    let ch = ref i in
    let crc = ref 0 in
    for _ = 0 to 7 do
      let b = !ch lxor !crc land 1 in
      crc := !crc lsr 1;
      let () =
        match equal b 0 with
        | true -> ()
        | false -> crc := !crc lxor static
      in
      ch := !ch lsr 1
    done;
    table.(i) <- !crc
  done;
  table
;;

let crc32 (bts : Bytes.t) =
  let static = 0xFF in
  lnot
    (Bytes.fold bts ~init:0xFFFFFFFF ~f:(fun acc chr ->
       let chr' = Char.to_int chr in
       let t = chr' lxor acc land static in
       (acc lsr 8) lxor Array.get table t))
[@@inline always]
;;

let static = 0xFF
let acc = ref 0xFFFFFFFF

let crc32_no_copy (bts : Bin_prot.Common.buf) (start : int) (len : int) =
  acc := 0xFFFFFFFF;
  for i = start to start + len - 1 do
    let chr = Bigarray.Array1.get bts i |> Char.to_int in
    let t = chr lxor !acc land static in
    acc := (!acc lsr 8) lxor Array.get table t
  done;
  lnot !acc
[@@inline always]
;;

let%expect_test _ =
  let res =
    crc32 (Bytes.of_string "123") |> Unsigned.UInt32.of_int |> Unsigned.UInt32.to_string
  in
  Format.printf "%s" res;
  [%expect {| 2286445522 |}]
;;

let%expect_test _ =
  let open Bin_prot in
  let buffer = Common.create_buf 10 in
  let string = Bytes.of_string "123" in
  let () =
    Common.blit_bytes_buf string ~src_pos:0 buffer ~dst_pos:0 ~len:(Bytes.length string)
  in
  let res =
    crc32_no_copy buffer 0 (Bytes.length string)
    |> Unsigned.UInt32.of_int
    |> Unsigned.UInt32.to_string
  in
  Format.printf "%s" res;
  [%expect {| 2286445522 |}]
;;
