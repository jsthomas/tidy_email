module Config : sig
  type t
  val make : api_key:string -> base_url:string -> t
end

val send : Config.t -> Tidy_email.Email.t -> (unit, string) Lwt_result.t
