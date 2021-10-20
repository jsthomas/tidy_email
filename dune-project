(lang dune 2.8)
(name tidy_email)

(generate_opam_files true)

(source (github jsthomas/tidy_email))
(license MIT)
(authors "Joe Thomas")
(maintainers "jsthomas@protonmail.com")

(package
 (name tidy_email)
 (synopsis "An OCaml library that simplifies connecting to email services")
 (description "\
tidy_email provides a consistent interface for sending email.
It defines types for sending messages via serveral different
backend services (SMTP, Mailgun, etc.). Also included is a simple
backend suitable for testing that captures messages without
sending them.
")
 (version 0.0.1)
 (depends
  (bisect_ppx (and (>= "2.5.0") :dev))
  (dune (>= 2.0))
  (ocaml (>= 4.11.0))
  (lwt (>= 5.4.2))))

(package
 (name tidy_email_mailgun)
 (synopsis "An OCaml library that simplifies connecting to Mailgun's REST API")
 (description "")
 (version 0.0.1)
 (depends
  (bisect_ppx (and (>= "2.5.0") :dev))
  (alcotest-lwt (and (>= "1.4.0") :with-test))
  (cmdliner (and (>= "1.0.4") :with-test))
  (dune (>= 2.0))
  (ocaml (>= 4.11.0))
  (cohttp (>= 2.5.5))
  (cohttp-lwt-unix (>= 2.5.5))
  (lwt_ppx (>= 2.0.0))
  (tidy_email (= :version))))

(package
 (name tidy_email_sendgrid)
 (synopsis "An OCaml library that simplifies connecting to Sendgrid's REST API")
 (description "")
 (version 0.0.1)
 (depends
  (bisect_ppx (and (>= "2.5.0") :dev))
  (alcotest-lwt (and (>= "1.4.0") :with-test))
  (cmdliner (and (>= "1.0.4") :with-test))
  (dune (>= 2.0))
  (ocaml (>= 4.11.0))
  (cohttp (>= 2.5.5))
  (cohttp-lwt-unix (>= 2.5.5))
  (lwt_ppx (>= 2.0.0))
  (yojson (>= 1.7.0))
  (tidy_email (= :version))))

(package
 (name tidy_email_smtp)
 (synopsis "An OCaml library that simplifies connecting to SMTP servers")
 (description "")
 (version 0.0.1)
 (depends
  (bisect_ppx (and (>= "2.5.0") :dev))
  (alcotest-lwt (and (>= "1.4.0") :with-test))
  (cmdliner (and (>= "1.0.4") :with-test))
  (dune (>= 2.0))
  (ocaml (>= 4.11.0))
  (letters (>= 0.3.0))
  (lwt_ppx (>= 2.0.0))
  (tidy_email (= :version))))
