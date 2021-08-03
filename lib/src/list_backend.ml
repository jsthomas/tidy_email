module Config = struct
  type t = Email.t list ref
end

let send (conf: Config.t) (e: Email.t) =
  conf := e :: !conf;
  Lwt.return_ok ()
