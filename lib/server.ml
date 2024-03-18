open Core
open Async
open Mealy

type events =
  [ `SetSuccess
  | `GetSuccess of string * string
  | `GetFail of string
  ]

let (event_r, event_w) : events Pipe.Reader.t * events Pipe.Writer.t = Pipe.create ()

let rec sink (machine : ('event, 'b) s) =
  let%bind result = Pipe.read' event_r in
  match result with
  | `Ok es ->
    let final = Queue.fold es ~init:machine ~f:(fun acc e -> snd (acc.action e)) in
    sink final
  | `Eof -> sink machine
;;

let rec handler buffer r length =
  match%bind Reader.read r buffer with
  | `Eof ->
    let converted = Stdlib.Bytes.sub_string buffer 0 length in
    return (Pipe.write_without_pushback event_w (`GetFail converted))
  | `Ok l -> handler buffer r (length + l)
;;

let run () =
  let port = Tcp.Where_to_listen.of_port 8765 in
  (* TODO! Reduce buffer usage. *)
  let f _addr r _w = handler (Bytes.create (4 * 1024)) r 0 in
  ignore
    (Tcp.Server.create ~max_connections:32 ~backlog:16 ~on_handler_error:`Raise port f)
;;
