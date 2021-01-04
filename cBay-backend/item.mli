(** 
   Representation of a single item in the marketplace.
*)

open Basic
open Offer

(** The type of the unique item ids. *)
type id = Basic.item_id[@@deriving to_yojson]

(** The type of the price of the items.*)
type price = Basic.item_price[@@deriving to_yojson]

(** The type of the unique name of the items.*)
type name = Basic.item_name[@@deriving to_yojson]

(** The type of the category of the items.*)
type category = Basic.item_category[@@deriving to_yojson]

(** The type of the description of the items.*)
type description = Basic.item_description[@@deriving to_yojson]

(** The user id of the seller of item.*)
type seller = Basic.user_id[@@deriving to_yojson]

(** Raised when an invalid item is attempted to be created. *)
exception InvalidItem of Basic.reason


(** The abstract type of values representing an item in the market. *)
type t = {id : id; price : price; name : name; category : category;
          description : description; seller : seller; offers : Offer.t list}
[@@deriving to_yojson]

(** [new_item id price name category description seller] is an item
    with fields corrseponding to the arguments. *)
val new_item : id -> price -> name -> category -> description -> seller -> t

(** [highest_offer items id] is the highest price of offer corresponding to 
    [item] in [items]. *)
val highest_offer : t -> Basic.item_price

(** [from_json j] is the item represented by the json [j] *)
val from_json : Yojson.Basic.t -> t
