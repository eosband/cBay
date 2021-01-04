(**
   Parsing of user terminal commands.
*)


(* Represents a user input, where the response is split up into a "command"
   word and possibly an object_list*)
type command = 
  | Offer
  | Buy
  | View
  | Sell
  | Menu
  | Logout
  | Quit

(* Raised when the user input is empty *)
exception Empty

(* Raised when the user input is not empty, but does not match a valid
   command formation *)
exception Unknown

(** [parse str] is a command created from user input [str], where str is 
    matched to its corresponding command.
    Requires: [str] is only letters, numbers, or spaces.
    Raises: [Empty] if [str] is empty or only spaces.
    Raises: [Malformed] if the string is not simply one word matching with 
    one of the command words.
*)
val parse : string -> command
