type body =
  | Text  of string
  | Html  of string
  | Mixed of string * string * string option

type t = {
  sender : string;
  recipients : string list;
  subject : string;
  body : body;
}

let make ~sender ~recipient ~subject ~body =
  { sender; recipients = [recipient]; subject; body }
