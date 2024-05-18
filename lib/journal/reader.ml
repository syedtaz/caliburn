open Core

module Reader : sig
  type t

  val compact : t -> Action.t list
end = struct
  type t = { fd : In_channel.t }

  let readline reader =
    let open Option.Let_syntax in
    let%bind line = In_channel.input_line reader.fd in
    return (Yojson.Basic.from_string line)
  ;;

  type memory_set = (string, Action.t) Hashtbl.t

  let update_tbl (action : Action.t) tbl = match action with
    | Put { key; _ } | Delete { key } -> begin
      Hashtbl.find_and_call tbl key
      ~if_found:(fun _ -> Hashtbl.update tbl key ~f:(fun _ -> action))
      ~if_not_found:(fun _ -> Hashtbl.add_exn tbl ~key:key ~data:action)
    end

  let compact reader =
    let rec foldline reader tbl = match readline reader with
      | Some v -> update_tbl (Action.of_json_exn v) tbl; foldline reader tbl
      | None -> tbl
    in
    let results = foldline reader (Hashtbl.create (module String)) in
    List.map ~f:(fun (_, value) -> value ) (Hashtbl.to_alist results)
end
