module type S = sig
  val setup : unit -> unit
  val teardown : unit -> unit
  val send : Email.t -> ((unit, string) result) Lwt.t
end

module NullBackend = struct
  let setup _ = ()
  let teardown _ = ()
  let send _ =
    Lwt.return (Ok ())
end


module type ListConfig = sig
  val emails : Email.t list ref
end


module ListBackend (C : ListConfig) = struct
  let setup () =
    C.emails := [];
    ()

  let teardown _ = ()

  let send e =
    C.emails := e :: !C.emails;
    Lwt.return (Ok ())
end
