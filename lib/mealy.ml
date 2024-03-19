(** State machines inspired by Crem (Perone & Karachalias, 2023). *)

(** Mealy machine. *)
type ('a, 'b, 's) t =
  { initial : 's
  ; action : 's -> 'a -> 'b * 's
  }

(** Mealy machine with implicit state. *)
type ('a, 'b) s = { action : 'a -> 'b * ('a, 'b) s }

(** [unfold] hides the state in an explicit Mealy machine. *)
let unfold { initial; action } =
  let rec go state =
    { action =
        (fun a ->
          match action state a with
          | b, t -> b, go t)
    }
  in
  go initial
;;

(** Sequential composition *)
let ( >>> ) (f : ('a, 'b, 's1) t) (g : ('b, 'c, 's2) t) =
  let initial = f.initial, g.initial in
  let action state msg =
    let output, newstate = f.action (fst state) msg in
    let output', newstate' = g.action (snd state) output in
    output', (newstate, newstate')
  in
  unfold { initial; action }
;;

(** Parallel composition *)
let ( *** ) (f : ('a, 'b, 's1) t) (g : ('c, 'd, 's2) t) =
  let initial = f.initial, g.initial in
  let action (state_f, state_g) (msg_f, msg_g) =
    let output, newstate = f.action state_f msg_f
    and output', newstate' = g.action state_g msg_g in
    (output, output'), (newstate, newstate')
  in
  unfold { initial; action }
;;
