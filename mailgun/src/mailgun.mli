type config = {
  api_key : string;
  base_url : string;
}

val send : config -> Tidy_email.Email.t -> (unit, string) Lwt_result.t
