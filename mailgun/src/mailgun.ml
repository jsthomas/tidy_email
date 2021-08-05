type config = {
  api_key : string;
  base_url : string;
}

let send conf (e : Tidy_email.Email.t) =
  let open Cohttp in
  let open Cohttp_lwt_unix in
  let param = match e.body with
    | Text t -> [("text", [t])]
    | Html h -> [("html", [h])]
    | Mixed (t,h,_) -> [("text", [t]); ("html", [h])]
  in
  let params =
    [
      ("from", [e.sender]);
      ("to", e.recipients);
      ("subject", [e.subject]);
    ] @ param in
  let cred = `Basic ("api", conf.api_key) in
  let uri = conf.base_url ^ "/messages" |> Uri.of_string in
  let headers = Header.add_authorization (Header.init ()) cred in
  let%lwt _ = Client.post_form uri ~params ~headers in
  Lwt.return_ok ()
