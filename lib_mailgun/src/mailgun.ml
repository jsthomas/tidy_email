module Email = Tidy_email.Email


module type Config = sig
  val api_key: string
  val base_url: string
end


module MailgunBackend (C : Config) = struct
  let setup () = ()
  let teardown () = ()
  let send (e: Email.t) =
    let open Cohttp in
    let open Cohttp_lwt_unix in

    let params = [
      ("from", [e.sender]);
      ("to", [e.recipient]);
      ("subject", [e.subject]);
      ("text", [e.text])
    ] in

    let cred = `Basic ("api", C.api_key) in
    let uri = C.base_url ^ "/messages" |> Uri.of_string in
    let headers = Header.add_authorization (Header.init ()) cred in
    let%lwt _ = Client.post_form uri ~params ~headers in
    Lwt.return (Ok ())
end
