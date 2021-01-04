(** 
   Represents the state of all users. 

   This module represents the data stored in the users file, including
   the unique username, the password, and the item_ids of their listed items. It 
   handles loading of that data from JSON as well as querying the data.
*)

open User
open Yojson.Basic

(** Represents the type of the userstate *)
type t = User.t list [@@deriving to_yojson]

(** Raised when a user was attempted to be created with a username 
    already occupied by an existing user. *)
exception UserIdTaken

(** Raised when an invalid user id was searched for in the list of user ids.
*)
exception InvalidId 

(** [users_from_json j] is the list of users that [j] represents.
    Requires: [j] is a valid JSON listed item representation. *)
val users_from_json : Yojson.Basic.t -> t 

(** [empty_user_state] creates an empty state of users. *)
val empty_user_state: unit -> t

(** [get_users users] is a set-like list of all of the user_ids in [users]. *)
val get_users : t -> User.id list

(** [get_user users user_id] is the user corresponding to [user_id] in [users]. 
    Raises: InvalidId when [user_id] is not associated to a user in [users]. *)
val get_user : t -> User.id -> User.t

(** [get_items users user] is the listed items of [user] 
    Requires: [user] is a valid username in [users] *)
val get_items : t -> User.id -> Basic.item_id list

(** [exists_user users user] is whether or not the user [user] exists in 
    [users]. A user exists if there is a record of a user with identical id and 
    password. *)
val exists_user : t -> User.t -> bool

(** [exists_user users username] is whether or not the username [username] 
    exists in [users]. *)
val exists_username : t -> User.id -> bool

(** [add_user users user] returns an updated user state after [user] is added to 
    [users].
    Raises: UserIdTaken when the username of [user] is already taken.*)
val add_user : t -> User.t -> t

(** [remove_user users user] returns an updated user state after [user] is 
    removed to [users].
    Raises: InvalidId when the username of user [r] is already taken.*)
val remove_user : t -> User.t -> t

(** [add_item_to_user users user_id item_id] adds [item_id] to the list of items 
    that the user associated with [user_id] has and returns an updated user 
    state with this information. 
    Requires: 
        [user_id] is a valid user id.
        [item_id] is a valid item id. *)
val add_item_to_user : t -> User.id -> Item.id -> t

(** [remove_item_from_user users user_id item_id] removes [item_id] from the 
    list of items that the user associated with [user_id] has and returns an 
    updated user state with this information. 
    Requires: 
        [user_id] is a valid user ID 
        [item_id] is a valid item ID  *)
val remove_item_from_user : t -> User.id -> Item.id -> t
