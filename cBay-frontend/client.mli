(** Class to handle client functionality as the middleman between main and the 
    server *)

open Item
open User
open Transaction
open Offer
open Lwt
open Cohttp
open Cohttp_lwt_unix
open Yojson.Basic.Util


(** The abstract type to represent the client. *)
type t = unit

(** Represents server response information. If [fst response] is [true],
    then [snd response] will contain the correctly typed information as [main]
    expects. If [fst bool] is [false], it will contain an error message. *)
type response = bool * string


(** Represents an error when the server request was unsuccessful, most likely
    means client put in an invalid combination of parameters. *)
exception DataError of string

(** Represents an error getting a response from the server with a message *)
exception ServerError of string

(** [connect ()] attempts to connect to the marketplace server. Returns [true] 
    if the connection was successfully established and [false] otherwise. *)
val connect : unit -> bool

(** [validate_username username] is [true] if [username] is NOT already taken
    in the marketplace. 
    Raises:
    [ServerError msg] if an error was encountered reaching the server.
    [DataError msg] if the data from the server could not be parsed according
    to the API. *)
val validate_username : User.id -> bool

(** [categories mp] gets a list of all categories in the marketplace.
    Raises:
    [ServerError msg] if an error was encountered reaching the server.
    [DataError msg] if the data from the server could not be parsed according
    to the API. *)
val categories : unit -> Item.category list

(** [sold_trans seller] is the list transactions in the markerplace for which 
    [seller] was the seller. 
    Raises:
    [ServerError msg] if an error was encountered reaching the server.
    [DataError msg] if the data from the server could not be parsed according
    to the API. *)
val sold_trans : Transaction.seller -> Transaction.t list 

(** [bought_trans buyer] is the list transactions in the markerplace for which 
    [buyer] was the buyer. 
    Raises:
    [ServerError msg] if an error was encountered reaching the server.
    [DataError msg] if the data from the server could not be parsed according
    to the API. *)
val bought_trans : Transaction.buyer -> Transaction.t list 

(** [all_trans user] is the list transactions in the markerplace for which 
    [user] was either the buyer or seller. 
    Raises:
    [ServerError msg] if an error was encountered reaching the server.
    [DataError msg] if the data from the server could not be parsed according
    to the API. *)
val all_trans : User.id -> Transaction.t list

(** [find_item id] is the item corresponding to [id].
    Raises:
    [ServerError msg] if an error was encountered reaching the server.
    [DataError msg] if the data from the server could not be parsed according
    to the API. *)   
val find_item : Item.id -> Item.t 

(** [get_items_of_cat cat_list] returns a list of all items that are of 
    one of the categories in [cat_list]. 
    Raises:
    [ServerError msg] if an error was encountered reaching the server.
    [DataError msg] if the data from the server could not be parsed according
    to the API. *)
val get_items_of_cat : Item.category list -> Item.t list

(** [get_items_of_user user] returns a list of all items that this user has
    listed. 
    Raises:
    [ServerError msg] if an error was encountered reaching the server.
    [DataError msg] if the data from the server could not be parsed according
    to the API. *)
val get_items_of_user : User.t -> Item.t list

(** [get_offers_of_user user] returns a tuple (offers, items) where [offers] is
    the list of all offers that the user currently has pending on other items 
    and [items] are the corresponding items that the offers are listed on.
    Raises:
    [ServerError msg] if an error was encountered reaching the server.
    [DataError msg] if the data from the server could not be parsed according
    to the API. *)
val get_offers_of_user : User.t -> Offer.t list * Item.t list

(** [sell_item item] lists [item] to the marketplace and returns the listed
    item's marketplace id.
    Raises:
    [ServerError msg] if an error was encountered reaching the server.
    [DataError msg] if the data from the server could not be parsed according
    to the API. *)
val sell_item : Item.t -> Item.id

(** [sell_item item user] causes [user] to buy [item] in the marketplace and,
    if successful, returns the transaction that occured as a result. 
    Raises:
    [ServerError msg] if an error was encountered reaching the server.
    [DataError msg] if the data from the server could not be parsed according
    to the API. *)
val buy_item : Item.id -> User.id -> Transaction.t

(** [make_offer offer] adds an [offer] to the marketplace and returns the
    id it was given. 
    Raises:
    [ServerError msg] if an error was encountered reaching the server.
    [DataError msg] if the data from the server could not be parsed according
    to the API. *)
val make_offer : Offer.t -> Offer.id

(** [accept_offer offer seller] accepts [offer] if [seller] was the original
    seller of the item that [offer] is attached to. If all goes well returns the
    transaction associated with the purchase. 
    Raises:
    [ServerError msg] if an error was encountered reaching the server.
    [DataError msg] if the data from the server could not be parsed according
    to the API. *)
val accept_offer : Offer.id -> User.id -> Transaction.t 

(** [decline_offer offer seller] declines [offer] if [seller] was the original
    seller of the item that [offer] is attached to and returns a unit.
    Raises:
    [ServerError msg] if an error was encountered reaching the server.
    [DataError msg] if the data from the server could not be parsed according
    to the API. *)
val decline_offer : Offer.id -> User.id -> unit

(** [create_user user] adds [user] to the marketplace as a user and returns a
    unit if all goes well. 
    Raises:
    [ServerError msg] if an error was encountered reaching the server, or if the
     username was already taken.
    [DataError msg] if the data from the server could not be parsed according
    to the API. *)
val create_user : User.t -> unit

(** [authenticate_user user] is [true] if the user with credentials defined in 
    [user] is valid, and false otherwise.
    Raises:
    [ServerError msg] if an error was encountered reaching the server, or if the
     username was already taken.
    [DataError msg] if the data from the server could not be parsed according
    to the API.
*)
val authenticate_user : User.t -> bool
