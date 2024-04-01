(**   B-Trees *)

open Core
module DL = Doubly_linked

type leaf
type internal

type 'a node =
  { mutable size : int
  ; mutable keys : 'a DL.t
  }
[@@deriving sexp]

type ('a, 'phantom) t =
  | Leaf : 'a node -> ('a, leaf) t
  | Internal : ('a node * ('a, _) t DL.t) -> ('a, internal) t

module Private = struct
  let t = 2
  let t' = (2 * t) - 1

  let nth (lst : 'a DL.t) n =
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

  let split_if_full : type a. (a, internal) t -> int -> a -> int =
    fun node i k ->
    match node with
    | Internal (data, children) ->
      let _child = nth children i in
      (* TODO! split_child node i *)
      let ith_key = nth data.keys i in
      (match Poly.( > ) k ith_key with
       | true -> i + 1
       | false -> i)
  ;;

  let rec insert_non_full : type a b. a -> (a, b) t -> unit =
    fun key tree ->
    match tree with
    | Leaf node ->
      let el = DL.find_elt node.keys ~f:(fun k -> Poly.(>) k key) |> Option.value_exn in
      let (_ : a DL.Elt.t) = DL.insert_before node.keys el key in
      node.size <- node.size + 1
    | Internal (node, children) ->
      let i, _child = DL.findi_elt node.keys ~f:(fun _ k -> Poly.(>) k key) |> Option.value_exn in (* TODO! FIXME *)
      let i' = split_if_full tree i key in
      insert_non_full key (nth children i')
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
