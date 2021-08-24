type config = {
  api_key : string;
  base_url : string;
}

type http_post_form =
  ?headers:Cohttp.Header.t ->
  params:(string * string list) list ->
  Uri.t ->
  (Cohttp.Response.t * Cohttp_lwt.Body.t) Lwt.t

val client_send :
  http_post_form -> config -> Tidy_email.Email.t -> (unit, string) Lwt_result.t

val send : config -> Tidy_email.Email.t -> (unit, string) Lwt_result.t
