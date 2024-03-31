open Core

module Node = struct

  type ('k, 'v) t =
    { order : int
    ; mutable keys : 'k Doubly_linked.t
    ; mutable values : 'v list Doubly_linked.t
    ; mutable leaf : bool
    }
  [@@deriving sexp]

  let create order =
    { order
    ; keys = Doubly_linked.create ()
    ; values = Doubly_linked.create ()
    ; leaf = true
    }
  ;;

  let is_full = function
    | { order; keys; _ } -> Int.equal order (Doubly_linked.length keys)
  ;;

  let nth_exn lst i =
    Doubly_linked.findi_elt lst ~f:(fun x _ -> Int.equal i x)
    |> Option.value_exn ~message:"value doesn't exist"
    |> snd
  ;;

  let rec add_aux
    (node : ('a, 'b) t)
    ~(key : 'a)
    ~(value : 'b)
    ~(keys : 'a list)
    (i : int)
    ~compf
    =
    let open Doubly_linked in
    match keys with
    | [] -> ()
    | h :: keys ->
      (match compf h key with
       | 0 ->
         let lst = nth_exn node.values i in
         Elt.set lst (value :: Elt.value lst)
       | x when x > 0 ->
         let el = nth_exn node.keys i in
         let (_ : 'a Elt.t) = insert_after node.keys el key in
         let v_el = nth_exn node.values i in
         let (_ : 'b list Elt.t) = insert_after node.values v_el [ value ] in
         ()
       | _ ->
         let (_ : 'a Elt.t) = insert_first node.keys key in
         let (_ : 'b list Elt.t) = insert_first node.values [ value ] in
         add_aux node ~key ~value ~keys (i + 1) ~compf)
  ;;

  let add node ~key ~value ~compf =
    let open Doubly_linked in
    match node with
    | { keys; values; _ } ->
      (match Int.equal (length keys) 0 with
       | true ->
         let (_ : 'a Elt.t) = insert_first node.keys key in
         let (_ : 'b list Elt.t) = insert_first values [ value ] in
         ()
       | false -> add_aux node ~key ~value ~keys:(to_list keys) 0 ~compf)
  ;;

  let split node =
    let open Doubly_linked in
    let mid = node.order / 2 in
    let lkeys, rkeys = partitioni_tf node.keys ~f:(fun i _ -> i < mid) in
    let lvals, rvals = partitioni_tf node.values ~f:(fun i _ -> i < mid) in
    let _left = { order = node.order; keys = lkeys; values = lvals; leaf = true} in
    let _right = { order = node.order; keys = rkeys; values = rvals; leaf = true} in
    let nkey = first_exn rkeys in
    node.leaf <- false;
    clear node.keys;
    clear node.values;
    node.keys <- of_list [ nkey];
    (* node.values <- of_list [left;right] *)
end

module Tests = struct
  open Node

  let%expect_test _ =
    let node = create 4 in
    Format.print_bool (is_full node);
    [%expect {| false |}]
  ;;

  (* Insert single key. *)
  let%expect_test _ =
    let node : (string, int) t = create 1 in
    add node ~key:"key" ~value:1 ~compf:String.compare;
    Format.print_bool (is_full node);
    [%expect {| true |}]
  ;;

  (* Representation single key. *)
  let%expect_test _ =
    let node : (string, int) t = create 1 in
    add node ~key:"key" ~value:1 ~compf:String.compare;
    Format.print_string
      (sexp_of_t String.sexp_of_t Int.sexp_of_t node |> Sexp.to_string_hum);
    [%expect {| ((order 1) (keys (key)) (values ((1))) (leaf true)) |}]
  ;;
end
