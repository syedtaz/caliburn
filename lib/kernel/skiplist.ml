open Core

module Make (S : Comparable.S) = struct
  type node =
    { data : S.t
    ; right : node option
    ; down : node option
    }

  let rec find (skiplo : node option) (v : S.t) : node option =
    let open Option.Let_syntax in
    let%bind node = skiplo in
    if S.equal node.data v
    then return node
    else (
      let%bind right = node.right in
      match S.( > ) right.data node.data with
      | true -> find node.down v
      | false -> find node.right v)
  ;;
end

(* Tests *)

module Tests = struct
  module M = Make (Int)
  open M

  let%expect_test _ =
    let node = { data = 1; right = None; down = None } in
    find (Some node) 0
    |> Option.value_map ~default:"Could not find." ~f:(fun z ->
      Format.sprintf "%d" z.data)
    |> Format.print_string;
    [%expect {| Could not find. |}]
  ;;

end
