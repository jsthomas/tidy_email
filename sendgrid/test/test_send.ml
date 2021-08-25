(* Note: The responses and status codes in this test suite are
   realistic examples of Sendgrid's API, as of August, 2021. Test data
   was gathered by making requests via Insomnia. *)

open Lwt.Infix

module Body = Cohttp_lwt.Body

module Email = Tidy_email.Email
module Sg = Tidy_email_sendgrid


let api_key = "test_password"
let base_url = "https://api.sendgrid.com/v3/mail/send"

let config : Sg.config = { api_key; base_url }

let text_body = Email.Text "Some text here."
let html_body = Email.Html "Some html here."
let mixed_body = Email.Mixed ("Some text here.", "Some html here.", None)


let email body =
  Tidy_email.Email.make
    ~sender:"sender@a.com"
    ~recipient:"receiver@b.com"
    ~subject:"Some title."
    ~body


let template = Stdlib.format_of_string
{|
{
   "personalizations": [{
      "to": [
        {"email": "receiver@b.com"}],
    	"subject": "Some title."
    }],
    "from": {"email": "sender@a.com"},
    "content": [
       {"type": "%s", "value": "%s"}
    ]
}
|}

let expected_request_body b =
  let in_string = ref false in
  let not_whitespace c =
    if c == '"' then
      let () = in_string := not !in_string in
      true
    else
      !in_string || not ((c == ' ') || (c == '\n') || (c == '\t'))
  in
  let content_type, content = match b with
    | Email.Text t -> "text/plain", t
    | Email.Html h -> "text/html", h
    | Email.Mixed (_, h, _) -> "text/html", h
  in
  Printf.sprintf template content_type content
  |> String.to_seq
  |> Seq.filter not_whitespace
  |> String.of_seq


let check_result =
  let testable =
    let print r =
      match r with
      | Ok () -> "OK"
      | Error e -> "Error: " ^ e in
    let eq = Result.equal ~ok:( == ) ~error:String.equal in
    let formatter ppf value = Format.pp_print_string ppf (print value) in
    Alcotest.testable formatter eq in
  Alcotest.check testable


let check_headers =
  let testable =
      let print h =
        match h with
        | None -> "None"
        | Some h -> Cohttp.Header.to_string h
      in
      let eq oh1 oh2 = match oh1, oh2 with
        | (None, None) -> true
        | (Some h1, Some h2) -> (Cohttp.Header.compare h1 h2 == 0)
        | _ -> false
      in
      let formatter ppf value = Format.pp_print_string ppf (print value) in
      Alcotest.testable formatter eq in
  Alcotest.check testable


(* This mock allows us to represent different status/body combinations
   that Sendgrid's API might produce. Binding in a response status,
   response body, and expected post body produces an http_post
   function. *)
let post
    (content: Email.body)
    status
    (response_body: Body.t)
    ?(body: Body.t option)
    ?headers
    uri =
  let response = Cohttp.Response.make ~status () in
  let expected_headers = Some (Cohttp.Header.of_list [
      ("authorization", "Bearer " ^ api_key);
      ("content-type", "application/json");
    ]) in
  let%lwt actual_post_body = match body with
    | None -> Lwt.return "None"
    | Some b -> Body.to_string b
  in
  Alcotest.(check string) "The correct API endpoint is used." base_url (Uri.to_string uri);
  check_headers "A basic auth header is supplied." expected_headers headers;
  Alcotest.(check string) "Body check" (expected_request_body content) actual_post_body;
  Lwt.return (response, response_body)


let bad_credentials_response = {|
{
  "errors": [
    {
      "message": "The provided authorization grant is invalid, expired, or revoked",
      "field": null,
      "help": null
    }
  ]
}
|}

let test_bad_credentials _ () =
  (* When Sendgrid replies with a 401 Unauthorized due to bad
     credentials, the send fails with an error. *)
  let client = post text_body `Unauthorized (Body.of_string bad_credentials_response) in
  let sender = Sg.client_send client in
  email text_body
  |> sender config
  >|= check_result "An error is produced." (Error bad_credentials_response)


let bad_data_response = {|
{
  "errors": [
    {
      "message": "Invalid type. Expected: array, given: object.",
      "field": "personalizations",
      "help": "http://sendgrid.com/docs/API_Reference/Web_API_v3/Mail/errors.html#-Personalizations-Errors"
    }
  ]
}
|}

let test_bad_data _ () =
  (* When Sendgrid replies with a 400 Bad Request, the function call
     converts the response to an error.

     The JSON tidy_email is submitting in this test is actually valid,
     but if Sendgrid changed their schema this is the error we would
     expect to see. *)
  let client = post text_body `Bad_request (Body.of_string bad_data_response) in
  let sender = Sg.client_send client in
  email text_body
  |> sender config
  >|= check_result "An error is produced." (Error bad_data_response)


let test_success body =
  let test _ () =
    (* The backend produces an ok when Sendgrid replies with a 202 Accepted.*)
    let client = post body `Accepted (Body.empty) in
    let sender = Sg.client_send client in
    email body |> sender config >|= check_result "An ok is produced." (Ok ())
  in
  test


let () =
  let open Alcotest_lwt in
  Lwt_main.run
  @@ run "Sendgrid Tests"
       [
         ("email errors",
           [
             test_case "Invalid Credentials" `Quick test_bad_credentials;
             test_case "Bad Data" `Quick test_bad_data;
           ] );
         ("email success cases",
          [
            test_case "Success - Text" `Quick (test_success text_body);
            test_case "Success - HTML" `Quick (test_success html_body);
            test_case "Success - Mixed" `Quick (test_success mixed_body);
          ]);
       ]
