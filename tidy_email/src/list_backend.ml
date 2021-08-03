type config = Email.t list ref

let send (conf : config) (e : Email.t) =
  conf := e :: !conf;
  Lwt.return_ok ()
