open Core

module Make (S : Common.Serializable) = struct
  module Serializer = Serializer.Make (S)

  type driver = string

  type input =
    [ `Set of S.key * S.value
    | `Del of S.key
    ]

  type output = input

  type state =
    { index : int
    ; chan : Out_channel.t
    }

  let handler { index; chan } event =
    let () =
      match event with
      | `Del key -> Serializer.serialize_key chan ~key
      | `Set (key, _value) -> Serializer.serialize_key chan ~key
    in
    event, { index = index + 1; chan }
  ;;

  let machine filename : (input, output, state) Mealy.t =
    let initial = { index = 0; chan = Out_channel.create ~append:true filename } in
    let action = handler in
    { initial; action }
  ;;
end