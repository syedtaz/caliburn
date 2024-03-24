open Core

type t =
  { total : int
  ; probability : float
  ; state : Random.State.t
  }

let create ~total ~probability =
  match total < 0 || Float.( >=. ) probability 1.0 || Float.( <=. ) probability 0.0 with
  | true -> None
  | false -> Some { total; probability; state = Random.State.make_self_init () }
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
