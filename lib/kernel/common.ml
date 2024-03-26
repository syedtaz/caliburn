module type Sig = sig
  type key
  type value

  val byte_of_key : key -> Bytes.t
  val byte_of_value : value -> Bytes.t
  val value_of_byte : Bytes.t -> value
end

module S = struct
  open Core

  type key = Bytes.t [@@deriving bin_io]
  type value = Bytes.t [@@deriving bin_io]
end

module type Serializable = sig
  type key
  type value

  val bin_write_key : key Bin_prot.Write.writer
  val bin_write_value : value Bin_prot.Write.writer
  val bin_size_key : key Bin_prot.Size.sizer
end

module X0 = struct
  open Core

  type key = int [@@deriving bin_io]
  type value = string [@@deriving bin_io]
end
