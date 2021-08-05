module Email = Tidy_email.Email
module Backend = Tidy_email_smtp.Smtp


let body = Email.Html {|
  <html>
  <body>
    <h3>Hello from Tidy-Email SMTP!<h3>
    <p>This is what an HTML body looks like.</p>
  </body>
  </html>
|}


let send sender recipient =
  let config = (Letters.Config.make
      ~username: (Sys.getenv "SMTP_USERNAME")
      ~password: (Sys.getenv "SMTP_PASSWORD")
      ~hostname: (Sys.getenv "SMTP_HOSTNAME")
      ~with_starttls:true)
  in
  let email = Email.make ~sender ~recipient
      ~subject:"A test html email from tidy-email, via SMTP."
      ~body
  in
  Printf.printf "Starting email send.\n";
  let%lwt result = Backend.send config email in
  let _ = match result with
  | Ok _ -> Printf.printf "Send succeeded.\n"
  | Error _ -> Printf.printf "Send failed.\n"
  in
  Lwt.return_unit


let run sender recipient =
  Lwt_main.run @@ send sender recipient


let () =
  let open Cmdliner in
  let doc = "The email address that should send the test message." in
  let sender = Arg.(required & pos 0 (some string) None & info [] ~docv: "sender" ~doc) in
  let doc = "The email address that should receive the test message." in
  let recipient = Arg.(required & pos 1 (some string) None & info [] ~docv:"receiver" ~doc) in
  let run_t = Term.((const run) $ sender $ recipient) in
  let doc = "Send a message from recipient to sender." in
  let info = Term.info "text_email" ~doc in
  Printf.printf "Starting.\n";
  Term.exit @@ (Term.eval (run_t, info))
