type t =
  { basepath : string
  ; maxsize : int
  ; mutable writer : Writer.t
  }