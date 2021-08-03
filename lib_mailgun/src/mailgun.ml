module Email = Tidy_email.Email

module Config = struct
  type t = {
    api_key: string;
    base_url: string
  }

  let make ~api_key ~base_url = { api_key; base_url }
end

let send (conf: Config.t) (e: Email.t) =
    let open Cohttp in
    let open Cohttp_lwt_unix in

    let params = [
      ("from", [e.sender]);
      ("to", [e.recipient]);
      ("subject", [e.subject]);
      ("text", [e.text])
    ] in

    let cred = `Basic ("api", conf.api_key) in
    let uri = conf.base_url ^ "/messages" |> Uri.of_string in
    let headers = Header.add_authorization (Header.init ()) cred in
    let%lwt _ = Client.post_form uri ~params ~headers in
    Lwt.return_ok ()
