open Core
open Async
open Caliburn

let () =
  Server.run ();
  don't_wait_for (Server.sink (Mealy.unfold Response.machine));
  never_returns (Scheduler.go ())
;;
