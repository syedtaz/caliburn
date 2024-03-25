open Core

let table =
  let open Unsigned.UInt32 in
  let table = Array.create ~len:256 zero in
  let static = of_int 0xEDB88320 in
  for i = 0 to 255 do
    let ch = ref (of_int i) in
    let crc = ref zero in
    for _ = 0 to 7 do
      let b = logand (logxor !ch !crc) one in
      crc := shift_right !crc 1;
      let () =
        match equal b zero with
        | true -> ()
        | false -> crc := logxor !crc static
      in
      ch := shift_right !ch 1
    done;
    table.(i) <- !crc
  done;
  table
;;

let crc32 (bts : Bytes.t) =
  let open Unsigned.UInt32 in
  let static = of_int 0xFF in
  lognot
    (Bytes.fold bts ~init:(of_int 0xFFFFFFFF) ~f:(fun acc chr ->
       let chr' = Char.to_int chr |> of_int in
       let t = logand (logxor chr' acc) static |> to_int in
       logxor (shift_right acc 8) (Array.get table t)))
;;

let%expect_test _ =
  let res = crc32 (Bytes.of_string "123") |> Unsigned.UInt32.to_string in
  Format.printf "%s" res;
  [%expect {| 2286445522 |}]
;;
