module type Sig = sig
  type key
  type value

  val byte_of_key : key -> Bytes.t
  val byte_of_value : value -> Bytes.t
  val value_of_byte : Bytes.t -> value
end

module S = struct
  type key = Bytes.t
  type value = Bytes.t

  let byte_of_key x = x
  let byte_of_value x = x
  let value_of_byte x = x
end
