type config = {
  api_key : string;
  base_url : string;
}


type http_post =
  ?body:Cohttp_lwt.Body.t ->
  ?headers:Cohttp.Header.t ->
  Uri.t -> (Cohttp.Response.t * Cohttp_lwt.Body.t) Lwt.t


val client_send :
  http_post
  -> config
  -> Tidy_email.Email.t
  -> (unit, string) Lwt_result.t


val send : config -> Tidy_email.Email.t -> (unit, string) Lwt_result.t
