type z = Z
type 'a s = Succ of 'a

type 'n nat =
  | Zero : z nat
  | Succ : 'n nat -> 'n s nat

type ('a, 'n) node =
  | Two of ('a, 'n) node * 'a * ('a, 'n) node
  | Three of ('a, 'n) node * 'a * ('a, 'n) node * 'a * ('a, 'n) node

type ('a, 'n) tree =
  | Branch : ('a, 'n) node -> ('a, 'n s) tree
  | Leaf : ('a, z) tree

type 'a t = Tree : ('a, 'n) tree -> 'a t