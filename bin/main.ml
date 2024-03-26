open Wal.Crc

let () =
  let open Bin_prot in
  let buffer = Common.create_buf 128 in
  let string =
    Bytes.of_string
      "wYdg5EHFIEEvfirSXp9Ktc9dGLVNklSfwYdg5EHFIEEvfirSXp9Ktc9dGLVNklSfwYdg5EHFIEEvfirSXp9Ktc9dGLVNklSf"
  in
  let () =
    Common.blit_bytes_buf string ~src_pos:0 buffer ~dst_pos:0 ~len:(Bytes.length string)
  in
  let _ = crc32_no_copy buffer 0 (Bytes.length string) in
  ()
;;
