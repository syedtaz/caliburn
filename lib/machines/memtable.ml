open Core
include Memtable_intf

(*  *)
module Make (S : Serializable) : Memtable with type key = S.key and type value = S.value = struct
  type key = S.key
  type value = S.value
  type state = (key, value) Hashtbl.t
  type event' = (key, value) event
  type response' = (key, value) response

  let handler (bucket : state) (event : event') : response' * state =
    match event with
    | `Insert (key, data) ->
      let prev = Hashtbl.find bucket key in
      Hashtbl.add_exn bucket ~key ~data;
      Insert (key, data, prev), bucket
    | `Get key -> PassedV (Hashtbl.find bucket key), bucket
    | `Delete key ->
      let prev = Hashtbl.find bucket key in
      Hashtbl.remove bucket key;
      Delete (key, prev), bucket
    | `UpdateFetch (key, f) ->
      Hashtbl.update bucket key ~f;
      (match Hashtbl.find bucket key with
       | Some v as ret -> Insert (key, v, ret), bucket
       | None -> PassedV None, bucket)
    | `FetchUpdate (key, f) ->
      let res = Hashtbl.find bucket key in
      Hashtbl.update bucket key ~f;
      (match res with
       | Some _ -> Insert (key, Hashtbl.find_exn bucket key, res), bucket
       | None -> PassedV res, bucket)
  ;;

  let machine : (event', response', state) Kernel.Mealy.t =
    { initial =
        Hashtbl.create
          (module struct
            type t = S.key

            let compare = S.compare_key
            let hash = S.hash_key
            let sexp_of_t = S.sexp_of_key
          end)
    ; action = handler
    }
  ;;

  let from_msgs events =
    let initial = machine.initial, machine in
    let _, m =
      List.fold_left events ~init:initial ~f:(fun m e ->
        let _, mach = m in
        let _, res = mach.action mach.initial e in
        res, mach)
    in
    m
  ;;
end
