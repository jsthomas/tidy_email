(** tidy_email_smtp is just a thin wrapper around letters to provide
   the same interface as the REST API sibling libraries. *)


module Config = Letters.Config
(** The primary data you will need to configure an SMTP connection are
   hostname, username, and password strings. *)


val send : Config.t -> Tidy_email.Email.t -> (unit, string) Lwt_result.t
(** Send the input email via SMTP.

   If the underlying request to the SMTP server is unsuccessful, the
   response body is provided in the result. *)
