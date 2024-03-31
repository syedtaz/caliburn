(**   B-Trees *)

open Core
module DL = Doubly_linked

type leaf
type 'a node =
  { mutable size : int
  ; keys : 'a DL.t
  }
[@@deriving sexp]

type ('a, 'phantom) t =
  | Leaf : 'a node -> ('a, leaf) t
  | Internal : ('a node * ('a, _) t DL.t) -> ('a, _) t

module Private = struct
  let nth (lst : ('a, 'b) t DL.t) n =
    DL.findi_elt lst ~f:(fun i _ -> i = n) |> Option.value_exn |> snd |> DL.Elt.value
  ;;

  let rec mem_aux : type a b. a -> (a, b) t -> bool =
    fun x -> function
    | Leaf { keys; _ } -> DL.mem keys x ~equal:Poly.( = )
    | Internal ({ keys; _ }, children) ->
      DL.fold_until
        keys
        ~init:0
        ~f:(fun i key ->
          match Poly.( > ) x key with
          | true -> Continue (i + 1)
          | false ->
            if Poly.( = ) x key then Stop true else Stop (mem_aux x (nth children i)))
        ~finish:(fun _ -> false)
  ;;
end

let mem tree x = Private.mem_aux x tree
let create () = Leaf { size = 0; keys = DL.create () }

module Tests = struct
  let%expect_test _ =
    let node = Leaf { size = 3; keys = DL.of_list [ 1; 2; 3 ] } in
    Format.print_bool (mem node 2);
    [%expect {| true |}]
  ;;

  let%expect_test _ =
    let node = Leaf { size = 3; keys = DL.of_list [ 1; 2; 3 ] } in
    Format.print_bool (mem node 0);
    [%expect {| false |}]
  ;;
end
