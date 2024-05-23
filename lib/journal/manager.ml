open Core

module Manager : sig
  type t

  val create : ?maxsize:int -> string -> t
  val append : t -> action:Action.t -> unit
end = struct
  type t =
    { maxsize : int
    ; directory : string
    ; mutable writer : Writer.t
    }

  let create ?maxsize directory =
    let size = Option.value_map maxsize ~default:1_000_000 ~f:(fun x -> x) in
    (* Track sequence numbers from snapshot. *)
    { maxsize = size; directory; writer = Writer.create ~sq:0 ~path:directory }
  ;;

  let append manager ~(action : Action.t) =
    let { maxsize; directory; writer } = manager in
    Writer.append writer ~action;
    match Writer.exceeds writer maxsize with
    | true ->
      Writer.close writer;
      let filename = Writer.filename writer in
      let data = Reader.create filename |> Reader.compact in
      Writer.rewrite writer data;
      (* Fix new file *)
      manager.writer <- Writer.create ~sq:0 ~path:(directory ^ "2.log")
    | false -> ()
  ;;
end