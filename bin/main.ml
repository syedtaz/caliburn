open Caliburn
open Core
module L = Log.Make (Kernel.Common.X0)

let internal = Kernel.Mealy.unfold (L.machine "somefile.log")

let () =
  let lst : L.input list = List.map ~f:(fun x -> `Del x) [ 1 ] in
  let _ = List.fold_left ~init:internal ~f:(fun acc x -> snd (acc.action x)) lst in
  ()
;;
