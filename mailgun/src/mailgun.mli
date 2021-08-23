type config = {
  api_key : string;
  base_url : string;
}

val send : config -> Tidy_email.Email.t -> (unit, string) Lwt_result.t

module type HttpClient = sig
  val post_form :
    ?ctx:Cohttp_lwt_unix.Net.ctx
  -> ?headers:Cohttp.Header.t
  -> params:(string * string list) list
  -> Uri.t
  -> (Cohttp.Response.t * Cohttp_lwt.Body.t) Lwt.t
end

module type MailgunClient = sig
  val send : config -> Tidy_email.Email.t -> (unit, string) Lwt_result.t
end

module Foo ( H : HttpClient ) : MailgunClient
