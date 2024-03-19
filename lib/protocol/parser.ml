open Angstrom

type command =
  [ `Set of string * string
  | `Get of string
  ]

let get =
  let open Let_syntax in
  let%bind key = string "get" *> char ',' *> take_while (fun _ -> true) in
  return (`Get key)
;;

let set =
  let open Angstrom.Let_syntax in
  let%bind key = string "set" *> char ',' *> take_till (fun x -> Char.equal x ',') <* char ',' in
  let%bind value = take_while (fun _ -> true) in
  return (`Set (key, value))
;;

let parse s = parse_string ~consume:All (get <|> set) s