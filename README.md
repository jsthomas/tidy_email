# tidy_email

This library wraps several different email services and simplifies the
process of sending mail.

The package `tidy_email` contains the definition for an email type and
an email backend that can be used in tests (it accumulates emails in a
list). An _email backend_ is simply a function that consumes a
configuration object and produces a function for sending email. In
`tidy_email` these email-sending functions have a consistent
signature. Related packages (e.g. `tidy_email_mailgun`) contain
provider specific logic and depend on `tidy_email`.

Using `tidy_email` makes it easier to hide some details of your email
provider from the rest of your application. This library can simplify
changing email services, should you need to do so.

Currently, `tidy_email` supports three different email integrations:

- [Mailgun REST API](https://documentation.mailgun.com/en/latest/api_reference.html)
- [Sendgrid REST API](https://docs.sendgrid.com/for-developers/sending-email/api-getting-started)
- SMTP, via `letters`.

(Both Mailgun and Sendgrid also support integrating with SMTP but
recommend using their respective REST API.)

## About Sendgrid and Mailgun

Both Sendgrid and Mailgun have extensive REST APIs. These services can
receive email as well as sending it. Currently, this library only
covers **sending** email. Advanced features like managing email
templates are not covered here. They could be added in the future;
pull requests and suggestions are welcome.

## Setting up a mail service

This section contains tips for setting up email access.

Mailgun is the only service I've encountered that provides a "sandbox
domain". If you don't plan to use Mailgun, you will first need to
register a domain (Route53 is a reasonable choice, most domains cost
~12 USD per year).

If you don't have a "sandbox domain", most email providers will need
you to create some combination of DNS records (typically TXT, CNAME,
and MX) in order for email to work. Both Sendgrid and Mailgun provide
straightforward instructions about which records to create.

If you're planning on sending marketing email, other automated email,
you may want to consider setting up a separate subdomain. For example,
if you run `foo.com`, you might us `mail.foo.com` for automated
email. Since the reputations for `foo.com` and `mail.foo.com` are
distinct, a separate subdomain ensures that a mistake in your
application won't impact the delivery of emails from `foo.com`
addresses. You can read more about this
[here](https://www.mailgun.com/blog/the-basics-of-email-subdomains/).

### Mailgun

This service is easy to set up and doesn't require a credit card until
you begin using custom domains. The "sandbox domain" feature is quite
helpful for running tests. This is the provider I recommend if you
don't have your own domain or SMTP server already.

You will need two pieces of information from the Mailgun console:

1. An API key. You may need to create this in the console first. For
   sandbox domains, this should exist already.

2. A "base url". In the US, this looks like
   `https://api.mailgun.net/v3/<Your Domain>`. In the EU, it may look
   slightly different, check the documentation.

Note: If you're working with a sandbox domain, you will also need to
configure which addresses the domain is allowed to send to. Expect
messages from a sandbox domain to go to your spam folder (the relevant
DNS records can't get set correctly because the domain is temporary).

### Sendgrid

Sendgrid requires a company email and website when setting up an
account. Using a generic email account (e.g. Protonmail, Gmail, etc.)
for this purpose is likely to result in your account application
getting frozen for several days while you negotiate with their
Customer Service audit team.

If you already have a domain and company email, registering with a
Sendgrid account is fast. Sendgrid's REST API is somewhat more
complicated than the one provided by Mailgun. Both services have a
free tier and aren't terribly expensive for small volumes of mail.

To use Sendgrid with `tidy-email`, you will need:

1. An API key. You'll need to create this in the console and set the
   permissions accordingly.

2. The URL for the Sendgrid API. As of this writing, this is
   `https://api.sendgrid.com/v3/mail/send`, but check the console to
   confirm.

### SMTP Server

This backend is the most generic. In order to utilize an SMTP server,
you will need to obtain the hostname, username, and password for the
server. Many email services support SMTP in addition to a REST API
(take, for example [Amazon
SES](https://docs.aws.amazon.com/ses/latest/dg/smtp-credentials.html)),
so this is a useful option if you want to use `tidy-email` with a
service that isn't supported by name yet.

## Examples

Each backend module (Mailgun, Sendgrid, and SMTP) contains a folder of
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
2. End-to-end tests that are run manually by maintainers.

To run the unit tests, navigate to the root of the repository and run
`dune test`. Running `./coverage.sh` will generate a summary of test
coverage via `bisect_ppx`. The coverage report will appear under
`_coverage/index.html`.

The specifications for the end to end tests are captured in the
`/examples` folder of each library. It's unfortunate that these tests
can't be captured in a public CI system, but testing requires
Mailgun/Sendgrid credentials that can't easily be shared.

## Other Design Suggestions

Sending an email is a fairly expensive operation; A REST API call to
Mailgun or Sendgrid may take ~500 ms or more. You may wish to use
`tidy_email` together with some sort of queuing system and/or a
background worker. This [blog
post](https://jsthomas.github.io/ocaml-email.html) provides
suggestions about how to do this.

## Acknowledgements

The implementation of `tidy_email_sendgrid` is based on work in
[Sihl](https://github.com/oxidizing/sihl).
