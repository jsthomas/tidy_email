module Config = Letters.Config

let backend config (e : Tidy_email.Email.t) =
  let sender = e.sender in
  let recipients = List.map (fun r -> Letters.To r) e.recipients in
  let subject = e.subject in
  let body =
    match e.body with
    | Text t -> Letters.Plain t
    | Html h -> Letters.Html h
    | Mixed (t, h, b) -> Letters.Mixed (t, h, b) in
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
