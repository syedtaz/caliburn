open Higher

module Fun = Newtype3 (struct
    type ('input, 'state, 'output) t = 'input -> 'output * 'state
  end)

type ('a, 'b) mealy' =
  { initial : 's. 's
  ; action : 's. 's -> 'a -> 'b * 's
  }

type ('a, 'b) mealy = { action : 'a -> 'b * ('a, 'b) mealy }

let unfold_mealy { initial; action } =
  let rec go s =
    { action =
        (fun a ->
          match action s a with
          | b, t -> b, go t)
    }
  in
  go initial
;;

type 'a topology = ('a * 'a list) list

type ('inp, 'out) state_machine =
  | Basic : ('inp, 'out) machine -> ('inp, 'out) state_machine
  | Sequential :
      ('inp, 'out) state_machine * ('inp, 'out) state_machine
      -> ('inp, 'out) state_machine
  | Parallel :
      ('inp1, 'out1) state_machine * ('inp2, 'out2) state_machine
      -> ('inp1, 'out2) state_machine

and ('inp, 'out) machine = Data of 'inp * 'out

type 'a transition =
  | Identity : 'a topology * 'a * 'a -> 'a transition

(* type msg =
   [ `NoData
  | `CollectedData
  | `CollectedLoan
  | `CollectedCredit
  | `CollectedAll
  ]

let top : msg topology =
   [ `NoData, [ `CollectedData ]
  ; `CollectedData, [ `CollectedLoan; `CollectedCredit ]
  ; `CollectedLoan, [ `CollectedAll ]
  ; `CollectedCredit, [ `CollectedAll ]
  ; `CollectedAll, []
  ] *)


(* type ('input, 'state, 'output) initial =
   | InitialState :
   ('input, 'state, 'output) Fun.s * 'input
   -> ('input, 'state, 'output) initial

   type ('input, 'state, 'output) action =
   | Action :
   'input topology * ('input, 'state, 'output) Fun.s * 'input * 'output
   -> ('input, 'state, 'output) action *)

(* type (_, _, _) allow_transition =
   | Identity : ('a, 'a, 'a) allow_transition
   | First : ('a * 'a list) list * 'a * 'b -> ('a, 'a, 'b) allow_transition *)

(* type ('message, 'state, 'output) machine =
  { state : 'state
  ; action : 'state -> 'message -> 'output * 'state
  }

let ( >> ) a b msg =
  let output, a' = a.action a.state msg in
  let final, b' = b.action b.state output in
  final, { state = a'; action = a.action }, { state = b'; action = b.action }
;;

type cart =
  | WaitingForPayment
  | InitiatingPayment
  | PaymentComplete

let cart_topology : cart topology =
  [ WaitingForPayment, [ InitiatingPayment ]
  ; InitiatingPayment, [ PaymentComplete ]
  ; PaymentComplete, []
  ]
;;

type 'a transition =
  | Identity : ('a topology * 'a * 'a) -> 'a transition
  | First : () *)
