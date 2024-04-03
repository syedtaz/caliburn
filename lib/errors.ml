type t =
  [ `None
  | `Cannot_determine
  | `Closed
  ]

let string_of_error (err : t) =
  match err with
  | `None -> "no error"
  | `Cannot_determine -> "cannot determine error"
  | `Closed -> "resource cannot be accessed"
;;