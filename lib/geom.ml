open Core

type t = int Sequence.t ref
type state = Random.State.t

let rec geometric (s : state) (p : float) (count : int) =
  let open Float in
  let generated = Random.State.float_range s 1.0 (1.0 / (1.0 - p)) in
  match generated - 1.0 < 0.001 with
  | true -> geometric s p (Int.( + ) count 1)
  | false -> count, s
[@@inline always]
;;

let create (p : float) : t =
  let state = Random.State.make_self_init ~allow_in_tests:false () in
  let seq =
    Sequence.unfold_step ~init:state ~f:(fun s ->
      let a, b = geometric s p 0 in
      Sequence.Step.Yield { state = b; value = a })
  in
  ref seq
;;

let next_exn (gen : t) =
  let open Option.Optional_syntax in
  match%optional Sequence.next !gen with
  | Some v ->
    gen := snd v;
    fst v
  | None -> raise (invalid_arg "no next in generator")
;;