(** 
   Representation of user data.
*)

open Basic

(** The type of the unique username. *)
type id = Basic.user_id
[@@deriving to_yojson]

(** The type of the password of the users.*)
type password = Basic.user_password
[@@deriving to_yojson]

(** Raised when an invalid user is attempted to be created. *)
exception InvalidUser of Basic.reason

type item_id = Basic.item_id[@@deriving to_yojson]


(** Represents the type of a User *)
type t = {id : id; password : password; listed : Basic.item_id list}
[@@deriving to_yojson]

(** [new_user id password] is a User with id [id] and password [password] *)
val new_user : id -> password -> t