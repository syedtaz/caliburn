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
  let%bind result = Pipe.read event_r in
  match result with
  | `Ok e ->
    let _, next = machine.action e in
    sink next
  | `Eof -> sink machine
;;

let rec handler buffer r =
  match%bind Reader.read r buffer with
  | `Eof ->
    let converted = Bytes.to_string buffer in
    return (Pipe.write_without_pushback event_w (`GetFail converted))
  | `Ok _ -> handler buffer r
;;

let run () =
  let port = Tcp.Where_to_listen.of_port 8765 in
  let f _addr r _w = handler (Bytes.create (16 * 1024)) r in
  ignore (Tcp.Server.create ~max_connections:32 ~backlog:16 ~on_handler_error:`Raise port f)
;;
