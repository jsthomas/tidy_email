open Lwt.Infix


let check_result =
  let testable =
    let print r =
      match r with
      | Ok () -> "OK"
      | Error e -> "Error: " ^ e
    in
    let eq = Result.equal ~ok:(==) ~error:String.equal in
    let formatter ppf value = Format.pp_print_string ppf (print value) in
    Alcotest.testable formatter eq
  in
  Alcotest.check testable


let post_form
    status
    body
    ?(ctx=Cohttp_lwt_unix.Net.default_ctx)
    ?headers
    ~params
    uri
  =
  let open Cohttp in
  let response = Response.make ~status () in
  let body = Cohttp_lwt.Body.of_string body in
  let header_str = match headers with
    | None -> "None"
    | Some h -> Cohttp.Header.to_string h
  in
  let render_parameter (k, vs) =
    Printf.sprintf "%s : %s" k (String.concat "," vs) in
  let param_str = String.concat "\n" (List.map render_parameter params) in

  let ctxt_str = Sexplib0__Sexp.to_string @@ Cohttp_lwt_unix.Net.sexp_of_ctx ctx in
  Printf.printf "Net context: %s" ctxt_str;
  Printf.printf "Headers: %s" header_str;
  Printf.printf "Params:\n %s" param_str;
  Printf.printf "URI:\n %s" @@ Uri.to_string uri;
  Lwt.return (response, body)

module InvalidCredsClient = struct
  let post_form = post_form `Forbidden "Invalid credentials"
end

let test_request _ () =
  let module Client = Tidy_email_mailgun.Mailgun.Foo (InvalidCredsClient) in
  let config : Tidy_email_mailgun.Mailgun.config = {
    api_key = "12345";
    base_url = "https://test.com/"
  } in
  let email = Tidy_email.Email.make
      ~sender:"sender@a.com"
      ~recipient:"receiver@b.com"
      ~subject:"subject"
      ~body:(Tidy_email.Email.Text "body")
  in
  Client.send config email
  >|= check_result "Failing assertion" (Error "Invalid credentials")


let () =
  let open Alcotest_lwt in
  Lwt_main.run
  @@ run "Mailgun Tests" [
    ("basic",
     [ test_case
         "Invalid credentials response"
         `Quick test_request]);]
