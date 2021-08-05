module Email = Tidy_email.Email
module Mailgun = Tidy_email_mailgun.Mailgun

let html_body =
  {|
  <html>
  <body>
    <h3>Hello from Tidy-Email!<h3>
    <p>This is what an HTML body looks like.</p>
  </body>
  </html>
|}

let send sender recipient =
  let config : Mailgun.config =
    {
      api_key = Sys.getenv "MAILGUN_API_KEY";
      base_url = Sys.getenv "MAILGUN_BASE_URL";
    } in
  let email =
    Email.make ~sender ~recipient
      ~subject:"A test html/text email from tidy-email."
      ~body:(Email.Html html_body) in
  Printf.printf "Starting email send.\n";
  let%lwt result = Mailgun.send config email in
  let _ =
    match result with
    | Ok _ -> Printf.printf "Send succeeded.\n"
    | Error _ -> Printf.printf "Send failed.\n" in
  Lwt.return_unit

let run sender recipient = Lwt_main.run @@ send sender recipient

let () =
  let open Cmdliner in
  let doc = "The email address that should send the test message message." in
  let sender =
    Arg.(required & pos 0 (some string) None & info [] ~docv:"sender" ~doc)
  in
  let doc = "The email address that should receive a test message." in
  let recipient =
    Arg.(required & pos 1 (some string) None & info [] ~docv:"receiver" ~doc)
  in
  let run_t = Term.(const run $ sender $ recipient) in
  let doc = "Send a message from recipient to sender." in
  let info = Term.info "text_email" ~doc in
  Printf.printf "Starting.\n";
  Term.exit @@ Term.eval (run_t, info)
