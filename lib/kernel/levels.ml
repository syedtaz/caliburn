open Core

type t =
  { total : int
  ; probability : float
  ; state : Random.State.t
  }

let create_with_state ~state ~total ~probability =
  match total < 0 || Float.( >=. ) probability 1.0 || Float.( <=. ) probability 0.0 with
  | true -> None
  | false -> Some { total; probability; state }
;;

let create ~total ~probability =
  create_with_state ~state:(Random.State.make_self_init ()) ~total ~probability
;;

let poll t =
  let { total; probability; state } = t in
  let h = ref 0 in
  let x = ref probability in
  let f = Float.( - ) 1.0 (Random.State.float state 1.0) in
  let rec aux () =
    match Float.( > ) !x f && !h + 1 < total with
    | true ->
      h := !h + 1;
      x := Float.( * ) !x probability;
      aux ()
    | false -> !h
  in
  aux ()
;;

let%expect_test _ =
  let l = { total = 10; probability = 0.2; state = Random.State.make [| 1; 2; 3; 4 |] } in
  Format.printf "%d" (poll l);
  [%expect {| 1 |}]
;;