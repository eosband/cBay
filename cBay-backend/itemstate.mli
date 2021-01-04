(** 
   Representation of static listed items data.

   This module represents the data stored in the listed items file, including
   the unique item id, the price of the item, and a description of all items. It 
   handles loading of that data from JSON as well as querying the data and 
   updating the item state based on interactions of marketplace.
*)

open Item
open Basic
open Yojson.Basic

(** The abstract type of values representing the listed items in the market. *)
type t = {
  items: Item.t list; 
  counter: int} 
[@@deriving to_yojson]

(** Raised when an invalid item was entered by client. *)
exception InvalidId

(** [from_json j] is the list of items that [j] represents.
    Requires: [j] is a valid JSON adventure representation. *)
val items_from_json : Yojson.Basic.t -> t 

(** [empty_item_state] creates an empty state of items. *)
val empty_item_state: unit -> t

(** [get_counter] is the counter of the Itemstate. *)
val get_counter: t -> int 

(** [get_item_categories items] is set-like list of all categories of listed 
    [items]. *)
val get_item_categories : t -> Item.category list

(** [item_ids items] is a set-like list of all of the item ids in 
    [items]. *)
val get_items : t -> Item.id list

(** [get_item_prices items] is the list of all of the prices of items in 
    [items]. *)
val get_item_prices : t -> Item.price list

(** [get_items_by_cat items cat] is a set-like list of all of the items in a 
    category [cat].
    Raises: InvalidCategory when an invalid category is entered. *)
val get_items_by_cat : t -> Item.category -> Item.t list

(** [remove_item items item_id] returns an updated item state resulting from 
    the removal of a corresponding to [item_id] is removed.
    Raises: InvalidId if [r] is not a valid item id in [a]. *)
val remove_item : t -> Item.id -> t

(** [add_item items new_item] returns an updated item state with [new_item] in 
    it.
    Raises: ItemIdTaken when the item id of [new_item] is already taken. *)
val add_item : t -> Item.t -> t

(** [find_item items item_id] is the item corresponding to [item_id] .
    Requires: [item_id] is a valid item id.
    Raises: InvalidId when [item_id] is not an id for an item in [items].*)
val find_item : t -> Item.id -> Item.t

(** [add_offer_to_item items item offer] returns an updated item state with 
    the [offer] to added to [item] in [items]. *)
val add_offer_to_item : t -> Item.t -> Offer.t -> t

(**[remove_offer_from_item items item offer] returns the updated item state with
   the [offer] removed from [item] in [items]. *)
val remove_offer_from_item : t -> Item.t -> Offer.t -> t 
