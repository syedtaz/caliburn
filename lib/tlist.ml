type 'a type_list =
  | [] : 'a type_list
  | ( :: ) : 'a * 'a type_list -> 'a type_list

type 'a topology = ('a * 'a type_list) type_list

type cart =
  [ `WaitingForPayment
  | `InitiatingPayment
  | `PaymentComplete
  ]

let simple =
  [ `InitiatingPayment, `PaymentComplete :: []
  ; `WaitingForPayment, `InitiatingPayment :: []
  ; `PaymentComplete, []
  ]
;;
