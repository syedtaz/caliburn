open Core
open Async

type command = Protocol.Parser.command

let (event_r, event_w) : command Pipe.Reader.t * command Pipe.Writer.t = Pipe.create ()
let source () = Source.generate event_r

let rec handler buffer r length =
  match%bind Reader.read r buffer with
  | `Eof ->
    let converted = Stdlib.Bytes.sub_string buffer 0 length in
    (match Protocol.Parser.parse converted with
     | Ok v -> return (Pipe.write_without_pushback event_w v)
     | Error _ -> return ())
  | `Ok l -> handler buffer r (length + l)
;;

let run () =
  let port = Tcp.Where_to_listen.of_port 8765 in
  (* TODO! Reduce buffer usage. *)
  let f _addr r _w = handler (Bytes.create (4 * 1024)) r 0 in
  ignore
    (Tcp.Server.create ~max_connections:32 ~backlog:16 ~on_handler_error:`Raise port f)
;;
