module Header = Cohttp.Header
module Body = Cohttp_lwt.Body
module Auth = Cohttp.Auth

type config = {
  api_key : string;
  base_url : string;
}

type http_post =
  ?body:Cohttp_lwt.Body.t ->
  ?headers:Cohttp.Header.t ->
  Uri.t ->
  (Cohttp.Response.t * Cohttp_lwt.Body.t) Lwt.t

let client_send (post : http_post) (conf : config) (e : Tidy_email.Email.t) =
  let param =
    match e.body with
    | Text t -> [("text", [t])]
    | Html h -> [("html", [h])]
    | Mixed (t, h, _) -> [("text", [t]); ("html", [h])] in
  let params =
    [("from", [e.sender]); ("to", e.recipients); ("subject", [e.subject])]
    @ param in
  let cred = `Basic ("api", conf.api_key) in
  let uri = conf.base_url ^ "/messages" |> Uri.of_string in
  let headers =
    Cohttp.Header.of_list
      [
        ("content-type", "application/x-www-form-urlencoded");
        ("authorization", Auth.string_of_credential cred);
      ] in
  let body = Body.of_string (Uri.encoded_of_query params) in
  let%lwt response, resp_body = post ~headers ~body uri in
  let%lwt body_content = Cohttp_lwt.Body.to_string resp_body in
  match Cohttp.Response.status response with
  | `OK -> Lwt.return_ok ()
  | _ -> Lwt.return_error body_content

let send =
  client_send
    (Cohttp_lwt_unix.Client.post ~ctx:Cohttp_lwt_unix.Net.default_ctx
       ~chunked:false)
