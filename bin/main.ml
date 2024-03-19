open Core
open Async
open Caliburn
open Caliburn.Mealy

let internal = Store.machine >>> Response.machine
let input = Server.source ()

let () =
  Server.run ();
  don't_wait_for (input.feed internal);
  never_returns (Scheduler.go ())
;;
