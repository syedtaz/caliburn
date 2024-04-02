open Core
include Bucket_intf

(* TODO! CHANGE THIS TO FD TREE ASAP *)

module Make (S : Serializable) : Bucket with type key = S.key and type value = S.value =
struct
  type key = S.key
  type value = S.value
  type t = (key, value) Hashtbl.t
  type error = |

  let bucket =
    Hashtbl.create
      (module struct
        type t = S.key

        let compare = S.compare_key
        let hash = S.hash_key
        let sexp_of_t = S.sexp_of_key
      end)
  ;;

  let insert key value : (value option, error) Result.t =
    let prev = Hashtbl.find bucket key in
    Hashtbl.add_exn bucket ~key ~data:value;
    Ok prev
  ;;

  let get key : (value option, error) Result.t = Ok (Hashtbl.find bucket key)

  let delete key : (value option, error) Result.t =
    let prev = Hashtbl.find bucket key in
    Hashtbl.remove bucket key;
    Ok prev
  ;;

  let mem key : (bool, error) Result.t = Ok (Hashtbl.mem bucket key)

  let update_fetch key ~f : (value Option.t, error) Result.t =
    Hashtbl.update bucket key ~f;
    Ok (Hashtbl.find bucket key)
  ;;

  let fetch_update key ~f : (value Option.t, error) Result.t =
    let res = Hashtbl.find bucket key in
    Hashtbl.update bucket key ~f;
    Ok res
  ;;
end
