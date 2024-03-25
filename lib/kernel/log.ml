module Make (S : Common.Sig) = struct
  open Core

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

  let entry_kv key value =
    let key' = S.byte_of_key key in
    let value' = S.byte_of_value value in
    let payload = Stdlib.Bytes.concat (Bytes.of_string "|") [ key'; value' ] in
    Wal.Record.of_bytes 0 ~payload |> Wal.Record.serialize
  [@@inline always]
  ;;

  let entry_k key =
    let payload = S.byte_of_key key in
    Wal.Record.of_bytes 0 ~payload |> Wal.Record.serialize
  [@@inline always]
  ;;

  let handler { index; chan } event =
    let () =
      match event with
      | `Set (key, value) -> Out_channel.fprintf chan "%s\n" (entry_kv key value)
      | `Del key -> Out_channel.fprintf chan "%s\n" (entry_k key)
    in
    event, { index = index + 1; chan }
  ;;

  let machine filename : (input, output, state) Mealy.t =
    let initial = { index = 0; chan = Out_channel.create ~append:true filename } in
    let action = handler in
    { initial; action }
  ;;
end

module ByteLog = Make (Common.S)