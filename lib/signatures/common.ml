open Core

module type Sig = sig
  type key
  type value

  val byte_of_key : key -> Bytes.t
  val byte_of_value : value -> Bytes.t
  val value_of_byte : Bytes.t -> value
end

module type Serializable = sig
  type key
  type value

  val compare_key : key -> key -> int
  val hash_key : key -> int
  val sexp_of_key : key -> Sexplib0.Sexp.t
  val bin_write_key : key Bin_prot.Write.writer
  val bin_write_value : value Bin_prot.Write.writer
  val bin_size_key : key Bin_prot.Size.sizer
  val bin_size_value : value Bin_prot.Size.sizer
  val bin_read_key : key Bin_prot.Read.reader
  val bin_read_value : value Bin_prot.Read.reader
  val bin_reader_key : key Bin_prot.Type_class.reader
  val bin_reader_value : value Bin_prot.Type_class.reader
  val bin_writer_value : value Bin_prot.Type_class.writer
  val bin_writer_key : key Bin_prot.Type_class.writer
end

module S = struct
  open Core

  type key = int [@@deriving bin_io, hash, sexp]
  type value = string [@@deriving bin_io, hash, sexp]
end
