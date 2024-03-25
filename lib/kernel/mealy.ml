type ('a, 'b, 's) t =
  { initial : 's
  ; action : 's -> 'a -> 'b * 's
  }

type ('a, 'b) s = { action : 'a -> 'b * ('a, 'b) s }

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

let ( >>> ) (f : ('a, 'b, 's1) t) (g : ('b, 'c, 's2) t) =
  let initial = f.initial, g.initial in
  let action state msg =
    let output, newstate = f.action (fst state) msg in
    let output', newstate' = g.action (snd state) output in
    output', (newstate, newstate')
  in
  { initial; action }
;;

let ( *** ) (f : ('a, 'b, 's1) t) (g : ('c, 'd, 's2) t) =
  let initial = f.initial, g.initial in
  let action (state_f, state_g) msg =
    let output, newstate = f.action state_f msg
    and output', newstate' = g.action state_g msg in
    (output, output'), (newstate, newstate')
  in
  { initial; action }
;;

module type Machine0 = sig
  type input
  type output
  type state

  val machine : (input, output) s
end

module type Machine1 = sig
  type input
  type output
  type state
  type driver

  val machine : driver -> (input, output, state) t
end