open Caliburn.Server
open Async
open Core

let () =
  run ();
  never_returns (Scheduler.go ())
;;
