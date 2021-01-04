(** 
   Representation of static offer transactions.

   This module represents the data stored in the transactions file, including
   the buyer, seller, price and item id of each occuring transaction. It handles 
   loading of that data from JSON as well as querying the data and updating the 
   transaction state based on interactions of marketplace. 
*)

open Transaction
open Yojson.Basic

(** The abstract type of representing the transactions in the market. *)
type t = Transaction.t list [@@deriving to_yojson]


(** Raised when a non item id was entered by client. *)
exception InvalidId


(** [transactions_from_json j] is the list of transactions that [j] represents.
    Requires: [j] is a valid JSON representation. *)
val transactions_from_json : Yojson.Basic.t -> t 

(** [empty_trans_state] creates an empty state of transactions. *)
val empty_trans_state: unit -> t

(** [add_transaction transactions trans] is an updated transaction state 
    resulting from  [trans] being added to [transactions].
    Requires: [trans] is a valid transaction. *)
val add_transaction : t -> Transaction.t -> t

(** [get_trans_by_seller transactions seller] is a set-like list of all of the 
    transactions in [transactions] that were sold by [seller].
    Requires: [seller] is a valid string. *)
val get_trans_by_seller : t -> Transaction.seller -> Transaction.t list

(** [get_trans_by_buyer transactions buyer] is a set-like list of all of the 
    transactions in [transactions] that we bought by [buyer].
    Requires: [buyer] is a valid string. *)
val get_trans_by_buyer : t -> Transaction.buyer -> Transaction.t list

(** [find_trans transactions id] is the transaction corresponding to [id] in 
    [transactions].
    Requires: [id] is a valid id.
    Raises: InvalidId when [id] is not an id for a transaction in [lst].*)
val find_trans : t -> Transaction.id -> Transaction.t
