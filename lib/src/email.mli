type t = {
  sender : string;
  recipient : string;
  subject : string;
  text : string;
  html : string option;
  cc : string list;
  bcc : string list
}
