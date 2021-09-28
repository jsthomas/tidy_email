type config = {
  api_key : string;  (** An alphanumeric string found on the Mailgun console. *)
  base_url : string;  (** e.g. https://api.mailgun.net/v3/<your domain> *)
}


val send : config -> Tidy_email.Email.t -> (unit, string) Lwt_result.t
(** This is the function most users should utilize for sending email.

   If the underlying request to Mailgun's API is unsuccessful, the
   response body is provided in the result.  *)


type http_post_form =
  ?headers:Cohttp.Header.t ->
  params:(string * string list) list ->
  Uri.t ->
  (Cohttp.Response.t * Cohttp_lwt.Body.t) Lwt.t


val client_send :
  http_post_form -> config -> Tidy_email.Email.t -> (unit, string) Lwt_result.t
(** This send function allows the caller to customize the HTTP request
   (a form post) made to Mailgun, by providing their own HTTP
   client as the first argument. *)
