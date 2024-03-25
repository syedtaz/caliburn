open Caliburn

module DB = Db.Make (struct
    type key = int
    type value = int
  end)

let x = DB.open_db "somepath"
