(* open Core
   open Async
   open Caliburn
   open Kernel.Mealy

   let internal = Store.machine >>> Response.machine *** Log.create "simple.log"
   let input = Server.source ()

   let () =
   Server.run ();
   don't_wait_for (input.feed (unfold internal));
   never_returns (Scheduler.go ())
   ;; *)

open Kernel
open Core

module L = Log.ByteLog

let internal : (L.input, L.output) Mealy.s =
  let open Kernel.Mealy in
  unfold (L.machine "somefile.log" >>> L.machine "someotherfile.log")
;;

let () =
  let lst =
    List.map
      [ "a", "a_v"; "b", "b_v" ]
      ~f:(fun (k, v) -> `Set (Bytes.of_string k, Bytes.of_string v))
  in
  ignore (List.fold_left lst ~init:internal ~f:(fun acc msg -> snd (acc.action msg)))
;;
