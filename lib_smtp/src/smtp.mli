module type Config = sig
  val conf : Letters.Config.t
end

module SmtpBackend (C: Config) : Tidy_email.Backend.S
