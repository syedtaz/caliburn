open Core
open Async

type ('a, 'b) t = { feed : ('a, 'b) Kernel.Mealy.s -> unit Deferred.t }

let generate (reader : 'a Pipe.Reader.t) =
  let rec f (m : ('a, 'b) Kernel.Mealy.s) =
    let%bind result = Pipe.read' reader in
    match result with
    | `Eof -> f m
    | `Ok es ->
      let final = Queue.fold es ~init:m ~f:(fun acc e -> snd (acc.action e)) in
      f final
  in
  { feed = f }
;;
