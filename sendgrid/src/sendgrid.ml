(* TODO :
   - No support for html.
   - Need to get a legitimate sendgrid account for testing purposes.
*)

type config = {
  api_key : string;
  base_url : string;
}

let body ~recipient ~subject ~sender ~content =
  let body : Yojson.Basic.t =
    `Assoc
      [
        ( "personalizations",
          `List
            [
              `Assoc
                [
                  ("to", `List [`Assoc [("email", `String recipient)]]);
                  ("subject", `String subject);
                ];
            ] );
        ("from", `Assoc [("email", `String sender)]);
        ( "content",
          `List
            [
              `Assoc [("type", `String "text/plain"); ("value", `String content)];
            ] );
      ] in
  Yojson.Basic.to_string body

let send conf (e : Tidy_email.Email.t) =
  let headers =
    Cohttp.Header.of_list
      [
        ("authorization", "Bearer " ^ conf.api_key);
        ("content-type", "application/json");
      ] in
  let sender = e.sender in
  let recipient = e.recipient in
  let subject = e.subject in
  let text_content = e.text in

  let req_body = body ~recipient ~subject ~sender ~content:text_content in
  let%lwt resp, _ =
    Cohttp_lwt_unix.Client.post
      ~body:(Cohttp_lwt.Body.of_string req_body)
      ~headers
      (conf.base_url |> Uri.of_string) in
  let status = Cohttp.Response.status resp |> Cohttp.Code.code_of_status in
  match status with
  | 200
  | 202 ->
    Lwt.return_ok ()
  | _ -> Lwt.return_error "Failed to send email"
