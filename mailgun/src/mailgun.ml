type config = {
  api_key : string;
  base_url : string;
}

module type HttpClient = sig
  val post_form :
    ?ctx:Cohttp_lwt_unix.Net.ctx
  -> ?headers:Cohttp.Header.t
  -> params:(string * string list) list
  -> Uri.t
  -> (Cohttp.Response.t * Cohttp_lwt__.Body.t) Lwt.t
end


module Foo ( H : HttpClient ) = struct
  let send conf (e : Tidy_email.Email.t) =
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
  let%lwt (response, body) = H.post_form uri ~params ~headers in
  let%lwt body_content = Cohttp_lwt.Body.to_string body in
  match Cohttp.Response.status response with
  | `OK -> Lwt.return_ok ()
  |  _ -> Lwt.return_error body_content
end


module type MailgunClient = sig
  val send : config -> Tidy_email.Email.t -> (unit, string) Lwt_result.t
end

module U = Foo ( Cohttp_lwt_unix.Client )

let send = U.send
