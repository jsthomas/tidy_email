module type Config = sig
  val api_key: string
  val base_url: string
end

module MailgunBackend (C : Config) : Tidy_email.Backend.S
