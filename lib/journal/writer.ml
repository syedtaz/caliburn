open Core

module Writer : sig
  type t

  val create : sq:int -> path:string -> t
  val append : t -> action:Action.t -> unit
  val close : t -> unit
  val exceeds : t -> int -> bool
  val filename : t -> string
  val rewrite : t -> Action.t list -> unit
end = struct
  type t =
    { fd : Core_unix.File_descr.t
    ; path : string
    ; mutable size : int
    ; mutable sq : int
    }

  module Private = struct
    let create_record (action : Action.t) =
      Action.to_json action |> Yojson.to_string |> String.(^) "\n" |> Bytes.of_string
    ;;

    let create_summary (sq : int) =
      `Assoc [ "sequence", `Int sq ]
      |> Yojson.to_string
      |> String.(^) "\n"
      |> Bytes.of_string
    ;;

    let write_and_sync writer buf =
      let open Core_unix in
      let written = single_write writer.fd ~buf in
      assert (written > 0);
      writer.size <- writer.size + written;
      fsync writer.fd;
      writer.sq <- writer.sq + 1
    ;;
  end

  let create ~(sq : int) ~(path : string) =
    let open Core_unix in
    let fd = openfile ~mode:[ O_CREAT; O_WRONLY; O_APPEND ] path in
    let t = { fd; path; size = 0; sq } in
    Private.write_and_sync t (Private.create_summary sq);
    t
  ;;

  let append writer ~(action : Action.t) =
    let buf = Private.create_record action in
    Private.write_and_sync writer buf
  ;;

  let close writer =
    let open Core_unix in
    fsync writer.fd;
    close writer.fd
  ;;

  let filename writer = Core_unix.File_descr.to_string writer.fd
  let exceeds t quant = t.size > quant

  let rewrite writer actions =
    let rewriter = create ~sq:0 ~path:(writer.path ^ ".xlog")in
    List.iter actions ~f:(fun x -> append rewriter ~action:x);
    close rewriter;
    Core_unix.remove (filename writer);
end

include Writer
