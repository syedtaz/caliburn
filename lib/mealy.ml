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
  unfold { initial; action }
;;
