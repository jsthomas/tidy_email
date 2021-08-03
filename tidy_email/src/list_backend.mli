type config = Email.t list ref

val send : config -> Email.t -> (unit, string) Lwt_result.t
