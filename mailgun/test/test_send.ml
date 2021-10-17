(* Note: The responses and status codes in this test suite are
   accurate representations of * how Mailgun's API works, as of
   August, 2021. Test data was gathered by making requests via
   Insomnia. *)

open Lwt.Infix
module Email = Tidy_email.Email
module Mg = Tidy_email_mailgun

let api_key = "test_password"

let config : Mg.config = { api_key; base_url = "https://api.com" }

let text_body = Email.Text "Some text here."

let html_body = Email.Html "Some html here."

let mixed_body = Email.Mixed ("Some text here.", "Some html here.", None)

let email body =
  Tidy_email.Email.make ~sender:"sender@a.com" ~recipient:"receiver@b.com"
    ~subject:"Some title." ~body

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
      | Some h -> Cohttp.Header.to_string h in
    let eq oh1 oh2 =
      match (oh1, oh2) with
      | None, None -> true
      | Some h1, Some h2 -> Cohttp.Header.compare h1 h2 == 0
      | _ -> false in
    let formatter ppf value = Format.pp_print_string ppf (print value) in
    Alcotest.testable formatter eq in
  Alcotest.check testable

let contains s sub =
  let m = String.length s in
  let n = String.length sub in
  let rec contains s sub i =
    i <= m - n && (String.equal sub (String.sub s i n) || contains s sub (i + 1))
  in
  contains s sub 0

(* This mock allows us to represent different status/body combinations
   that Mailgun's API might produce. Binding in a response status,
   response body, and expected post body produces an http_post_form
   function.*)
let post (post_body : Tidy_email.Email.body) status resp_body
    ?(body : Cohttp_lwt.Body.t option) ?headers uri =
  let open Cohttp in
  let response = Response.make ~status () in
  let resp_body = Cohttp_lwt.Body.of_string resp_body in
  let expected_headers =
    Some
      (Header.add_authorization
         (Header.init_with "content-type" "application/x-www-form-urlencoded")
         (`Basic ("api", api_key))) in
  let additional_params =
    match post_body with
    | Text _ -> ["text"]
    | Html _ -> ["html"]
    | Mixed _ -> ["text"; "html"] in
  let expected_params = ["from"; "to"; "subject"] @ additional_params in
  let%lwt actual_post_body =
    match body with
    | None -> Lwt.return "None"
    | Some b -> Cohttp_lwt.Body.to_string b in
  let all_params_present =
    List.fold_left
      (fun x p -> x && contains actual_post_body p)
      true expected_params in
  Alcotest.(check string)
    "The correct API endpoint is used." "https://api.com/messages"
    (Uri.to_string uri);
  check_headers "A basic auth header is supplied." expected_headers headers;
  Alcotest.(check bool)
    "The expected parameters are present." all_params_present true;
  Lwt.return (response, resp_body)

let test_bad_credentials _ () =
  (* When Mailgun replies with a 401 Unauthorized due to bad
     credentials, the send fails with an error. *)
  let client = post text_body `Unauthorized "Forbidden" in
  let send = Mg.backend ~client config in
  email text_body
  |> send
  >|= check_result "An error is produced." (Error "Forbidden")

let bad_data_response =
  {|
{
  "message": "'to' parameter is not a valid address. please check documentation"
}
|}

let test_bad_data _ () =
  (* When Mailgun replies with a 400 Bad Request, the function call
     converts the response to an error. *)
  let client = post text_body `Bad_request bad_data_response in
  let send = Mg.backend ~client config in
  email text_body
  |> send
  >|= check_result "An error is produced." (Error bad_data_response)

let ok_response =
  {|
{
  "id": "<20210823170937.1.7C6EB132B58E7372@testdomain.com>",
  "message": "Queued. Thank you."
}
|}

let test_success body =
  let test _ () =
    (* The backend produces an ok when Mailgun replies with a 200 OK.*)
    let client = post body `OK ok_response in
    let send = Mg.backend ~client config in
    email body |> send >|= check_result "An ok is produced." (Ok ())
  in
  test

let () =
  let open Alcotest_lwt in
  Lwt_main.run
  @@ run "Mailgun Tests"
       [
         ( "email errors",
           [
             test_case "Invalid Credentials" `Quick test_bad_credentials;
             test_case "Bad Data" `Quick test_bad_data;
           ] );
         ( "email success cases",
           [
             test_case "Success - Text" `Quick (test_success text_body);
             test_case "Success - HTML" `Quick (test_success html_body);
             test_case "Success - Mixed" `Quick (test_success mixed_body);
           ] );
       ]
