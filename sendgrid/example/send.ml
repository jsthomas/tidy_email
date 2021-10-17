module Email = Tidy_email.Email
module Sendgrid = Tidy_email_sendgrid

let html_body =
  Email.Html
    {|
  <html>
  <body>
    <h3><b>Hello from Tidy-Email!</b><h3>
    <p>This is what an HTML email body looks like.</p>
  </body>
  </html>
|}

let text_body = Email.Text "This is what a plain text email body looks like."

let send use_html sender recipient =
  let send = Sendgrid.backend
    {
      api_key = Sys.getenv "SENDGRID_API_KEY";
      base_url = Sys.getenv "SENDGRID_BASE_URL";
    } in
  let subject = "A test text email from tidy_email via Sendgrid." in
  let body = if use_html then html_body else text_body in
  let email = Email.make ~sender ~recipient ~subject ~body in
  Printf.printf "Starting email send.\n";
  let%lwt result = send email in
  let exit_code =
    match result with
    | Ok _ ->
      Printf.printf "Send succeeded.\n";
      0
    | Error _ ->
      Printf.printf "Send failed.\n";
      1 in
  Lwt.return exit_code

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
    Arg.(value & flag & info ["h"; "html"] ~docv:"html" ~doc) in

  let run_t = Term.(const run $ kind $ sender $ recipient) in
  let doc = "Send a message from recipient to sender." in
  let info = Term.info "text_email" ~doc in
  Printf.printf "Starting.\n";
  let result = Term.eval (run_t, info) in
  let result' = match result with
    | `Ok 1 -> `Error `Exn
    | _ -> result
  in
  Term.exit @@ result'
