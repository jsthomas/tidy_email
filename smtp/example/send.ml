module Email = Tidy_email.Email
module Backend = Tidy_email_smtp.Smtp


let html_body =
  Email.Html
    {|
  <html>
  <body>
    <h3>Hello from Tidy-Email SMTP!<h3>
    <p>This is what an HTML body looks like.</p>
  </body>
  </html>
|}

let text_body = Email.Text "This is what a plain text email body looks like."

let send use_html sender recipient =
  let config =
    Letters.Config.make
      ~username:(Sys.getenv "SMTP_USERNAME")
      ~password:(Sys.getenv "SMTP_PASSWORD")
      ~hostname:(Sys.getenv "SMTP_HOSTNAME")
      ~with_starttls:true in
  let body = if use_html then html_body else text_body in
  let email =
    Email.make ~sender ~recipient
      ~subject:"Test message from tidy-email via SMTP" ~body in
  Printf.printf "Starting email send.\n";
  let%lwt result = Backend.send config email in
  let _ =
    match result with
    | Ok _ -> Printf.printf "Send succeeded.\n"
    | Error e -> Printf.printf "Send failed. Details: %s" e in
  Lwt.return_unit


let run kind sender recipient = Lwt_main.run @@ send kind sender recipient


let () =
  let open Cmdliner in

  let sender =
    let doc = "The sender's email address." in
    Arg.(required & pos 0 (some string) None & info [] ~docv:"sender" ~doc)
  in

  let recipient =
    let doc = "The receiver's email address." in
    Arg.(required & pos 1 (some string) None & info [] ~docv:"receiver" ~doc)
  in

  let kind =
    let doc = "Send an HTML message instead of plain text." in
    Arg.(value & flag & info ["h"; "html"] ~docv:"html" ~doc)
  in

  let run_t = Term.(const run $ kind $ sender $ recipient) in
  let doc = "Send a message from recipient to sender." in
  let info = Term.info "text_email" ~doc in
  Printf.printf "Starting.\n";
  Term.exit @@ Term.eval (run_t, info)
