open Core

type entry =
  | Put of int * string
  | Del of int

type t = { mutable contents : entry list }

let create () = { contents = [] }
let put (k, v) page = page.contents <- Put (k, v) :: page.contents
let delete k page = page.contents <- Del k :: page.contents

let print_entry = function
  | Put (k, v) -> Format.printf "%d: %s;" k v
  | Del k -> Format.printf "%d;" k
;;

let compact { contents = p1 } { contents = p2 } =
  let rec f seen acc = function
    | [] -> seen, acc
    | Put (k, v) :: t ->
      if Set.mem seen k then f seen acc t else f (Set.add seen k) (Put (k, v) :: acc) t
    | Del k :: t -> if Set.mem seen k then f seen acc t else f (Set.add seen k) acc t
  in
  let set, temp = f (Set.empty (module Int)) [] p2 in
  let _, final = f set temp p1 in
  { contents = List.rev final }
;;

(* Tests *)

let%expect_test _ =
  let page = create () in
  put (1, "value") page;
  List.iter page.contents ~f:(fun e -> print_entry e);
  [%expect {| 1: value; |}]
;;

let%expect_test _ =
  let page = create () in
  delete 1 page;
  List.iter page.contents ~f:(fun e -> print_entry e);
  [%expect {| 1; |}]
;;

let%expect_test _ =
  let page = create () in
  put (1, "value") page;
  delete 1 page;
  let page_two = compact page (create ()) in
  List.iter page_two.contents ~f:(fun e -> print_entry e);
  [%expect {| |}]
;;

let%expect_test _ =
  let page = create () in
  put (1, "value") page;
  delete 1 page;
  put (2, "value") page;
  let page_two = compact page (create ()) in
  List.iter page_two.contents ~f:(fun e -> print_entry e);
  [%expect {| 2: value; |}]
;;
