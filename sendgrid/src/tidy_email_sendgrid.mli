type config = {
  api_key : string;  (** An alphanumeric string found on the Sendgrid console. *)
  base_url : string; (** e.g. https://api.sendgrid.com/v3/mail/send *)
}

type http_post =
  ?body:Cohttp_lwt.Body.t ->
  ?headers:Cohttp.Header.t ->
  Uri.t ->
  (Cohttp.Response.t * Cohttp_lwt.Body.t) Lwt.t

val backend :
  ?client:http_post -> config -> Tidy_email.Email.t -> (unit, string) Lwt_result.t
(** If the underlying request to Sendgrid's API is unsuccessful, the
   response body is provided in the result.

   client allows the user to customize how their HTTP post is
   performed. Most users will want to use the default. *)
