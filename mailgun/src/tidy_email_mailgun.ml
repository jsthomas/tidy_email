type config = {
  api_key : string;
  base_url : string;
}

type http_post_form =
  ?headers:Cohttp.Header.t ->
  params:(string * string list) list ->
  Uri.t ->
  (Cohttp.Response.t * Cohttp_lwt.Body.t) Lwt.t

let client_send (post_form : http_post_form) (conf : config)
    (e : Tidy_email.Email.t) =
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
  let headers = Cohttp.Header.add_authorization (Cohttp.Header.init ()) cred in
  let%lwt response, body = post_form uri ~params ~headers in
  let%lwt body_content = Cohttp_lwt.Body.to_string body in
  match Cohttp.Response.status response with
  | `OK -> Lwt.return_ok ()
  | _ -> Lwt.return_error body_content

let send =
  client_send
    (Cohttp_lwt_unix.Client.post_form ~ctx:Cohttp_lwt_unix.Net.default_ctx)
