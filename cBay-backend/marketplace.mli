(** 
   Representation of the state of marketplace.

   This module represents the data stored in marketplace database files, 
   including the listings, users, and transactions. It handles loading of 
   that data from JSON as well as querying the data and updating state
   based on interactions of marketplace.
*)

open Item
open User
open Transaction
open Offer
open Itemstate
open Userstate
open Transactionstate

(** The abstract type to represent the marketplace. *)
type t = { 
  item_state: Itemstate.t;
  user_state: Userstate.t;  
  trans_state : Transactionstate.t 
}

(** Raised when an invalid offer was attempted to be accepted or declined. *)
exception InvalidOfferEntered

(** [new_marketplace] returns an empty marketplace with no information about 
    users or items. *)
val new_marketplace : unit -> t

(** [read_marketplace] returns marketplace after reading  from database. *)
val read_marketplace : unit -> t

(** [read_test_marketplace] returns a test marketplace after reading from 
    database. FOR TESTING PURPOSES ONLY *)
val read_test_marketplace : unit -> t

(** [get_item_state mp] returns the item_state of the [mp] *)
val get_item_state : t -> Itemstate.t

(** [get_user_state mp] returns the user_state of the [mp] *)
val get_user_state : t -> Userstate.t

(** [get_trans_state mp] returns the trans_state of the [mp] *)
val get_trans_state : t -> Transactionstate.t

(** [validate_username mp username] checks if [username] already exists in the 
    [mp]. *)
val validate_username : t -> User.id -> bool

(** [categories mp] gets a list of categories of all items in the [mp].*)
val categories : t -> Item.category list

(** [sold_trans mp user] is the list transactions in [mp] for which [user] 
    was the seller.
    Requires: [user] is a valid string. *)
val sold_trans : t -> Transaction.seller -> Transaction.t list 

(** [boughts_trans mp user] is the list transactions in the [mp] for which user 
    was the seller.
    Requires: [user] is a valid string *)
val bought_trans : t -> Transaction.buyer -> Transaction.t list 

(** [find_item mp id] is the item corresponding to [id] in the [mp].
    Requires: [id] is a valid item id.
    Raises: InvalidId when [item_id] is not an id for an item in the [mp].*)   
val find_item : t -> Item.id -> Item.t 

(** [find_trans mp id] is the transaction corresponding to [id] in the [mp].
    Requires: [id] is a valid id.
    Raises: InvalidId when [id] is not an id for a transaction in the [mp].*)
val find_trans : t -> Transaction.id -> Transaction.t

(** [get_items_of_cat mp cat_list] returns a list of all items that are of 
    one of the categories in [cat_list] in the [mp]. *)
val get_items_of_cat : t -> Item.category list -> Item.t list

(** [get_items_by_user mp username ] returns a list of all items are currently 
    listed by [username].
    Requires: [username] is a valid User.id already in the marketplace.*)
val get_items_by_user : t -> User.id -> Item.t list

(** [sell_item mp item] adds [item] to the [mp] and returns 
    an updated marketplace containing a listing for that [item]. *)
val sell_item : t -> Item.t -> Item.id * t  

(** [buy_item mp item user_id] removes [item] from the [mp] and returns 
    an updated marketplace without [item].
    Raises InvalidID when an invalid item ID is entered.
    Requires: [userid] is a valid username already in [mp] *)
val buy_item : t -> Item.id -> Basic.user_id -> Transaction.t * t

(** [make_offer mp offer] adds an [offer] to the [mp] and returns an updated
    marketplace. *)
val make_offer : t -> Offer.t -> Offer.id * t

(** [find_offer mp offer_id] is the offer corresponding to the [offer_id] in the
    [mp]. 
    Raises: 
        InvalidID if [offer_id] does not correspond to a valid item and 
        InvalidOfferEntered if the offer does not exist to the corresponding 
        [offer_id] *)
val find_offer : t -> Offer.id -> Offer.t

(** [accept_offer mp offer seller] accepts [offer] and returns an updated
    marketplace. *)
val accept_offer : t -> Offer.id -> Basic.user_id -> Transaction.t * t  

(** [decline_offer mp offer] declines [offer] and returns an updated
    marketplace. *)
val decline_offer : t -> Offer.id -> t 

(** [get_offers_by_user user_id] returns all offers made by this user that 
    are pending with all the item information of those offers.  *)
val get_offers_by_user : t -> Offer.buyer -> Offer.t list * Item.t list

(** [create_user mp user] adds [user] to the [mp] and returns an updated 
    marketplace. *)
val create_user : t -> User.t -> t

(** [authenticate_user mp user] is true if [user] exists in [mp]. *)
val authenticate_user : t -> User.t -> bool

(** [write_marketplace mp] writes the information of [mp] to the database. *)
val write_marketplace : t -> unit