module Config : sig
  type t = Email.t list ref
end


val send : Config.t -> Email.t -> (unit, string) Lwt_result.t
