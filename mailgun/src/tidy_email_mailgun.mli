type config = {
  api_key : string;  (** An alphanumeric string found on the Mailgun console. *)
  base_url : string;  (** e.g. https://api.mailgun.net/v3/<your domain> *)
}

type http_post =
  ?body:Cohttp_lwt.Body.t ->
  ?headers:Cohttp.Header.t ->
  Uri.t ->
  (Cohttp.Response.t * Cohttp_lwt.Body.t) Lwt.t

val backend : ?client:http_post -> config -> Tidy_email.Email.t -> (unit, string) Lwt_result.t
