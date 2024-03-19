open Angstrom

type command =
  [ `Set of string * Bytes.t
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
  return (`Set (key, Bytes.of_string value))
;;

let parse s = parse_string ~consume:All (get <|> set) s