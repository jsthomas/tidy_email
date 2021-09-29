type config = {
  api_key : string;  (** e.g. https://api.sendgrid.com/v3/mail/send *)
  base_url : string;
      (** An alphanumeric string found on the Sendgrid console. *)
}

val send : config -> Tidy_email.Email.t -> (unit, string) Lwt_result.t
(** This is the function most users should utilize for sending email.

   If the underlying request to Sendgrid's API is unsuccessful, the
   response body is provided in the result. *)

type http_post =
  ?body:Cohttp_lwt.Body.t ->
  ?headers:Cohttp.Header.t ->
  Uri.t ->
  (Cohttp.Response.t * Cohttp_lwt.Body.t) Lwt.t

val client_send :
  http_post -> config -> Tidy_email.Email.t -> (unit, string) Lwt_result.t
(** This send function allows the caller to customize the HTTP request
   (a form post) made to Sendgrid by providing their own HTTP
   client as the first argument. *)
