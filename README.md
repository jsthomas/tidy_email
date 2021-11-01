# tidy_email

This library wraps several different email services and simplifies the
process of sending mail. Let's look at an example:

```ocaml
module Email = Tidy_email.Email
module Mailgun = Tidy_email_mailgun

let send = Mailgun.backend {
    api_key = Sys.getenv "MAILGUN_API_KEY";
    base_url = Sys.getenv "MAILGUN_BASE_URL";
  }

let () =
  let email =
    Email.make
      ~sender:"no-reply@mg.glenmeretechnologies.com"
      ~recipient:"jsthomas@protonmail.com"
      ~subject:"A small message"
      ~body:(Email.Text "Hi there!") in
  let u = Lwt_main.run (send email) in
  match u with
  | Ok _ -> print_string "Send succeeded."; exit 0
  | Error _ -> print_string "Send failed."; exit 1
```

The library defines two main entities an email type and an email
backend. Email backends are defined so that switching email providers
requires minimal changes.

Currently, `tidy_email` supports three different email services:

- [Mailgun REST API](https://documentation.mailgun.com/en/latest/api_reference.html)
- [SendGrid REST API](https://docs.sendgrid.com/for-developers/sending-email/api-getting-started)
- SMTP, via [`letters`](https://github.com/oxidizing/letters/).

Each service is factored out into its own library; for example, to
integrate with SendGrid, use `tidy_email_sendgrid`.

## About SendGrid and Mailgun

First things first! Here are links to use for setting up a new mail
plan:

- To sign up for Mailgun, click [here](https://signup.mailgun.com/new/signup).
- To sign up for SendGrid, click [here](https://sendgrid.com/pricing/).

The sections below contain a more extensive comparison of these two
services.

Both SendGrid and Mailgun have extensive REST APIs (in fact, they also
support SMTP but recommend their APIs). These services can receive
email as well as sending it. Currently, this library only covers
**sending** email. Advanced features like managing email templates are
not covered here. They could be added in the future; pull requests and
suggestions are welcome.

## Configuring mail service

This section contains tips for configuring your mail plan.

Mailgun is the only service I've encountered that provides a "sandbox
domain". A sandbox domain allows you to send email to a limited number
of configured email addresses, without having to register a domain.

If you don't plan to use a sandbox domain, you will first need to
register a domain (Route53 is a reasonable choice, most domains cost
~12 USD per year). In this case, most email providers will need you to
create some combination of DNS records (typically TXT, CNAME, and MX)
in order for email to work. Both SendGrid and Mailgun provide
straightforward instructions about which records to create.

If you're planning on sending marketing email or other automated
email, consider setting up a separate subdomain to protect the
reputation of your main domain. For example, if you own `foo.com` you
might use `mail.foo.com` for automated email. Since the reputations
for `foo.com` and `mail.foo.com` are distinct, a mistake in your
application won't impact the delivery of emails from `foo.com`
addresses. You can read more about this
[here](https://www.mailgun.com/blog/the-basics-of-email-subdomains/).

### Mailgun

This service is easy to set up and doesn't require a credit card until
you begin using custom domains. The "sandbox domain" feature is quite
helpful for running tests, though it's common for sandbox domain
emails to go directly to your spam folder. This is the provider I
recommend if you don't have your own domain or SMTP server already.

You will need two pieces of information from the Mailgun console:

1. An API key. You may need to create this in the console first. For
   sandbox domains, this should exist already.

2. A "base url". In the US, this looks like
   `https://api.mailgun.net/v3/<Your Domain>`. In the EU, it may look
   slightly different; check the documentation.

Note: If you're working with a sandbox domain, you will also need to
configure which addresses the domain is allowed to send to. Expect
messages from a sandbox domain to go to your spam folder (the relevant
DNS records can't get set correctly because the domain is temporary).

### SendGrid

SendGrid requires a company email and website when setting up an
account. Using a generic email account (e.g. Protonmail, Gmail, etc.)
for this purpose is likely to result in your account getting frozen
for several days while you negotiate with their security/audit team.

If you already have a domain and company email, registering with a
SendGrid account is fast. SendGrid's REST API is somewhat more
complicated than the one provided by Mailgun. Both services have a
free tier and aren't terribly expensive for small volumes of mail.

To use SendGrid with `tidy_email`, you will need:

1. An API key. You'll need to create this in the console and set the
   permissions accordingly.

2. The URL for the SendGrid API. As of this writing, this is
   `https://api.sendgrid.com/v3/mail/send`, but check the console to
   confirm.

### SMTP Server

This backend is the most generic. In order to utilize an SMTP server,
you will need to obtain the hostname, username, and password for the
server. Many email services support SMTP in addition to a REST API
(take, for example [Amazon
SES](https://docs.aws.amazon.com/ses/latest/dg/smtp-credentials.html)),
so this is a useful option if you want to use `tidy_email` with a
service that isn't supported by name yet.

## Examples

Each backend module (Mailgun, SendGrid, and SMTP) contains a folder of
examples. To run an example, copy the relevant `send.sh.template` file
to `send.sh` and populate the missing environment
variables. Running `./send.sh` should print:

```
Starting.
Starting email send.
Send succeeded.
```

and then a single message should appear in the destination inbox.

## How this package is tested

There are two levels of testing in this project:

1. Unit tests defined using `alcotest`.
2. Integration tests that run as part of Github Actions CI on a merge.

To run the unit tests, navigate to the root of the repository and run
`dune test`. Running `./coverage.sh` will generate a summary of test
coverage via `bisect_ppx`. The coverage report will appear under
`_coverage/index.html`.

The specifications for the integration tests are captured in the
`/examples` folder of each library. Although the API keys used by
Github Actions can't be shared, you can set up your own
Mailgun/Sendgrid account to run tests against your own keys.

## Other Design Suggestions

Sending an email is a fairly expensive operation; A REST API call to
Mailgun or SendGrid may take ~500 ms or more. You may wish to use
`tidy_email` together with some sort of queuing system and/or a
background worker. This [blog
post](https://jsthomas.github.io/ocaml-email.html) provides
suggestions about how to do this.

## Contact

The best place to record feature requests and bugs is in the
[issues](https://github.com/jsthomas/tidy_email/issues) section of
this repo.

I am also available on Discord and Discuss:

- #dream on the [Reason Discord](https://discord.gg/YCTDuzbg).
- #webdev on the [OCaml Discord](https://discord.gg/DyhPFYGr)
- The [OCaml Discuss forum](https://discuss.ocaml.org/).

Tagging comments with `@jsthomas` is a good way to get my attention.

## Contributing

Pull requests and other contributions (examples, bug reports, better
documentation) are welcome.

## Acknowledgements

The implementation of `tidy_email_sendgrid` is based on work in
[Sihl](https://github.com/oxidizing/sihl).
