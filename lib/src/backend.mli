module type S = sig
  val setup : unit -> unit
  val teardown : unit -> unit
  val send : Email.t -> ((unit, string) result) Lwt.t
end

(* This backend discards any messages it is asked to send. *)
module NullBackend : S

module type ListConfig = sig
  val emails : Email.t list ref
end

(* This backend adds any messages it is asked to send to an internal list. *)
module ListBackend (C : ListConfig) : S
