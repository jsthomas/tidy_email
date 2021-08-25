module Config = Letters.Config

val send : Config.t -> Tidy_email.Email.t -> (unit, string) Lwt_result.t
