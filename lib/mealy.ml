type ('a, 'b, 's) mealy' =
  { initial : 's
  ; action : 's -> 'a -> 'b * 's
  }

type ('a, 'b) mealy = { action : 'a -> 'b * ('a, 'b) mealy }

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