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
 (description
 "Tidy-email provides a consistent interface for sending email.")
 (version 0.0.0)
 (depends
  (dune (>= 2.0))
  (ocaml (>= 4.11.0))
  (emile (>= 1.1))
  (cohttp (>= 2.5.5))
  (cohttp-lwt-unix (>= 2.5.5))))

(package
 (name tidy_email_mailgun)
 (synopsis "An OCaml library that simplifies connecting to email services")
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
