(** 
   Representation of static offer data.

   This module represents the data stored in the offers file, including
   the username of the buyer, the username of the seller, the price of the 
   offer, and the id of the item. It handles loading of that data from JSON as 
   well as querying the data.
*)

open Basic

(** Raised when an invalid offer is attempted to be created. *)
exception InvalidOffer of Basic.reason

(** The type of the price of the offer.*)
type price = Basic.item_price[@@deriving to_yojson]

(** The buyer of the items.*)
type buyer = Basic.user_id[@@deriving to_yojson]

(** The type of an offer id. *)
type id = string

(** Represents the type of an offer *)
type t = {
  buyer : buyer; 
  price : price; 
  item_id : Basic.item_id [@key "item id"];
  id : id
}
[@@deriving to_yojson ]

(** [new_offer buyer price item_id] is a new offer object with buyer [buyer], 
    price [price], and item_id [item_id] *)
val new_offer : buyer -> price -> Basic.item_id -> string -> t

(** [from_json j] is the offer represented by the json [j] *)
val from_json : Yojson.Basic.t -> t

