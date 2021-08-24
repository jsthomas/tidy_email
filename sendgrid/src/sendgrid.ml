module Email = Tidy_email.Email


type config = {
  api_key : string;
  base_url : string;
}


let body ~recipients ~subject ~sender ~(content: Email.body) =
  let to_block = List.map (fun r -> ("email", `String r)) recipients in
  let content_block = match content with
    | Text t -> `Assoc [("type", `String "text/plain"); ("value", `String t)];
    | Html h -> `Assoc [("type", `String "text/html"); ("value", `String h)];
    | Mixed (_, h, _) -> `Assoc [("type", `String "text/html"); ("value", `String h)];
  in
  let body : Yojson.Basic.t =
    `Assoc
      [
        ( "personalizations",
          `List
            [
              `Assoc
                [
                  ("to", `List [`Assoc to_block]);
                  ("subject", `String subject);
                ];
            ] );
        ("from", `Assoc [("email", `String sender)]);
        ( "content",
          `List
            [
              content_block
            ] );
      ] in
  Yojson.Basic.to_string body


type http_post =
  ?body:Cohttp_lwt.Body.t ->
  ?headers:Cohttp.Header.t ->
  Uri.t -> (Cohttp.Response.t * Cohttp_lwt.Body.t) Lwt.t


let client_send (post: http_post) (conf: config) (e : Tidy_email.Email.t) =
  let headers =
    Cohttp.Header.of_list
      [
        ("authorization", "Bearer " ^ conf.api_key);
        ("content-type", "application/json");
      ] in
  let sender = e.sender in
  let recipients = e.recipients in
  let subject = e.subject in
  let req_body = body ~recipients ~subject ~sender ~content:e.body in
  let%lwt resp, resp_body =
     post
       ~body:(Cohttp_lwt.Body.of_string req_body)
       ~headers
       (conf.base_url |> Uri.of_string) in
  let%lwt resp_content = Cohttp_lwt.Body.to_string resp_body in
  let status = Cohttp.Response.status resp |> Cohttp.Code.code_of_status in
  match status with
  | 200
  | 202 -> Lwt.return_ok ()
  | _ -> Lwt.return_error (resp_content)


let send =
  client_send
    (Cohttp_lwt_unix.Client.post ~ctx:Cohttp_lwt_unix.Net.default_ctx ~chunked:false)
