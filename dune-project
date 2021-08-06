(lang dune 2.8)
(name tidy-email)

(generate_opam_files true)

(source (github jsthomas/tidy-email))
(license MIT)
(authors "Joe Thomas")
(maintainers "jsthomas@protonmail.com")

(package
 (name tidy_email)
 (synopsis "An OCaml library that simplifies connecting to email services")
 (description "\
Tidy-email provides a consistent interface for sending email.
It provides types for sending messages via serveral different
backend services (SMTP, Mailgun, etc.). Also included is a simple
backend suitable for testing that captures messages without
sending them.
")
 (version 0.0.0)
 (depends
  (dune (>= 2.0))
  (ocaml (>= 4.11.0))
  (lwt (>= 5.4.2))))

(package
 (name tidy_email_mailgun)
 (synopsis "An OCaml library that simplifies connecting to Mailgun's REST API.")
 (description "")
 (version 0.0.0)
 (depends
  (dune (>= 2.0))
  (ocaml (>= 4.11.0))
  (cohttp (>= 2.5.5))
  (cohttp-lwt-unix (>= 2.5.5))
  (tidy-email (>= 0.0.0))))

(package
 (name tidy_email_smtp)
 (synopsis "An OCaml library that simplifies connecting to SMTP servers.")
 (description "")
 (version 0.0.0)
 (depends
  (dune (>= 2.0))
  (ocaml (>= 4.11.0))
  (letters (>= 0.2.1))
  (tidy-email (>= 0.0.0))))
