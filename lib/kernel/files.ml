let open_or_create path =
  match Sys_unix.file_exists ~follow_symlinks:true path with
  | `Yes -> Core_unix.openfile ~mode:[ O_WRONLY; O_APPEND ] path
  | `Unknown | `No ->
    let dirname = Filename.dirname path in
    Core_unix.mkdir_p dirname;
    Core_unix.openfile ~mode:[ O_CREAT; O_RDWR ] path