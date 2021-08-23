(* Note: The responses and status codes in this test suite are
   accurate representations of * how Mailgun's API works, as of
   August, 2021. Test data was gathered by making requests via
   Insomnia. *)

open Lwt.Infix

(* For these tests the content of the configuration and the email aren't especially important,
 *  there can just be one pair used across all tests.
 *)
let config : Tidy_email_mailgun.Mailgun.config =
  { api_key = "12345"; base_url = "https://test.com/" }

let email =
  Tidy_email.Email.make ~sender:"sender@a.com" ~recipient:"receiver@b.com"
    ~subject:"Some title." ~body:(Tidy_email.Email.Text "Some text here.")

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

(* This mock allows us to represent different status/body combinations
   that Mailgun's API might produce. *)
let post_form status body ?headers ~params uri =
  let open Cohttp in
  let response = Response.make ~status () in
  let body = Cohttp_lwt.Body.of_string body in
  let header_str =
    match headers with
    | None -> "None"
    | Some h -> Cohttp.Header.to_string h in
  let render_parameter (k, vs) =
    Printf.sprintf "%s : %s" k (String.concat "," vs) in
  let param_str = String.concat "\n" (List.map render_parameter params) in
  Printf.printf "Headers: %s" header_str;
  Printf.printf "Params:\n %s" param_str;
  Printf.printf "URI:\n %s" @@ Uri.to_string uri;
  Lwt.return (response, body)

let test_bad_credentials _ () =
  (* When Mailgun replies with a 401 Unauthorized, because bad credentials
     were supplied, an email send fails with an error. *)
  let client = post_form `Unauthorized "Forbidden" in
  let sender = Tidy_email_mailgun.Mailgun.client_send client in
  sender config email
  >|= check_result "An error is produced." (Error "Forbidden")

let ok_response =
  {|
{
  "id": "<20210823170937.1.7C6EB132B58E7372@testdomain.com>",
  "message": "Queued. Thank you."
}
|}

let test_success _ () =
  (* When Mailgun replies with a 200 OK, the function call produces an ok. *)
  let client = post_form `OK ok_response in
  let sender = Tidy_email_mailgun.Mailgun.client_send client in
  sender config email >|= check_result "An ok is produced." (Ok ())

let bad_data_response =
  {|
{
  "message": "'to' parameter is not a valid address. please check documentation"
}
|}

let test_bad_data _ () =
  (* When Mailgun replies with a 400 Bad Request, the function call converts
   *  the response to an error. *)
  let client = post_form `Bad_request bad_data_response in
  let sender = Tidy_email_mailgun.Mailgun.client_send client in
  sender config email
  >|= check_result "An error is produced." (Error bad_data_response)

let () =
  let open Alcotest_lwt in
  Lwt_main.run
  @@ run "Mailgun Tests"
       [
         ( "basic",
           [
             test_case "Invalid Credentials" `Quick test_bad_credentials;
             test_case "Success" `Quick test_success;
             test_case "Bad Data" `Quick test_bad_data;
           ] );
       ]
