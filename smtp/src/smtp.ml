module Config = Letters.Config

let send config (e : Tidy_email.Email.t) =
  let sender = e.sender in
  let recipients = [Letters.To e.recipient] in
  let subject = e.subject in
  let body = Letters.Plain e.text in
  let mail = Letters.build_email ~from:sender ~recipients ~subject ~body in
  match mail with
  | Ok message -> (
    try%lwt
      let%lwt _ = Letters.send ~config ~sender ~recipients ~message in
      Lwt.return_ok ()
    with
    | e ->
      let error = Printf.sprintf "Error: %s" (Printexc.to_string e) in
      Lwt.return_error error)
  | Error msg -> Lwt.return_error msg
