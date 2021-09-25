(** Clients of tidy_email may want a mock email backend suitable for
   unit tests.  The backend described in this module accumulates
   messages in a list for later analysis.  *)

type config = Email.t list ref

val send : config -> Email.t -> (unit, string) Lwt_result.t
