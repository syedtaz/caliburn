open Core
include Memtable_intf


module Make (S : Serializable) : Memtable with type key = S.key and type value = S.value =
struct
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
      `Insert (key, prev), bucket
    | `Get key -> `PassedV (Hashtbl.find bucket key), bucket
    | `Delete key ->
      let prev = Hashtbl.find bucket key in
      Hashtbl.remove bucket key;
      `Delete (key, prev), bucket
    | `FetchUpdate (key, f) ->
      Hashtbl.update bucket key ~f;
      `Insert (key, (Hashtbl.find bucket key)), bucket
    | `UpdateFetch (key, f) ->
      let res = Hashtbl.find bucket key in
      Hashtbl.update bucket key ~f;
      `PassedV res, bucket
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
end
