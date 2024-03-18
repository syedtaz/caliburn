open Core
open Async

(* Thanks to https://dev.realworldocaml.org/concurrent-programming.html *)

let rec copy_blocks buffer r w =
  match%bind Reader.read r buffer with
  | `Eof -> return ()
  | `Ok bytes_read ->
    Writer.write w (Bytes.to_string buffer) ~len:bytes_read;
    let%bind () = Writer.flushed w in
    copy_blocks buffer r w
;;

let run () =
  let port = Tcp.Where_to_listen.of_port 8765 in
  let f _ r w = copy_blocks (Bytes.create (16 * 1024)) r w in
  let server = Tcp.Server.create ~on_handler_error:`Raise port f in
  ignore server
;;