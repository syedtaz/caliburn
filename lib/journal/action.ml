type t =
  | Put of
      { key : string
      ; payload : Bytes.t
      }
  | Delete of { key : string }

module Private = struct
  open Yojson.Basic.Util

  let data json = member "data" json |> to_string |> Bytes.of_string
  let key json = member "key" json |> to_string
  let action_type json = member "type" json |> to_string
end

let to_json = function
  | Put { key; payload } ->
    `Assoc
      [ "type", `String "put"
      ; "key", `String key
      ; "data", `String (Bytes.to_string payload)
      ]
  | Delete { key } -> `Assoc [ "type", `String "delete"; "key", `String key ]
;;

let of_json_exn json =
  let open Private in
  match action_type json with
  | "put" -> Put { key = key json; payload = data json }
  | "delete" -> Delete { key = key json }
  | _ -> raise (Invalid_argument "cannot parse json")
;;
