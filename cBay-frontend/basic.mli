(**
   A file to store all the basic types shared among Item, User, and Offer types.
   Created to prevent circular usage in those types.
*)

(** The type of an item id *)
type item_id = int[@key "item id"][@@deriving to_yojson]

(** The type of an item price *)
type item_price = float[@@deriving to_yojson]

(** The type of an item name. *)
type item_name = string[@@deriving to_yojson]

(** The type of an item category. *)
type item_category = string[@@deriving to_yojson]

(** The type of an item description. *)
type item_description = string[@@deriving to_yojson]

(** The type of a user id *)
type user_id = string[@@deriving to_yojson]

(** The type of a user password *)
type user_password = string[@@deriving to_yojson]

(** Standard type of a reason used for an exception *)
type reason = string
