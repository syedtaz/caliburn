let flush chan () = Core.Out_channel.flush chan

let ( <* ) a b =
  b ();
  a
;;