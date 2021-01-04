
(**Representation of transaction data 
*)

open Basic

(** The type of the unique transaction id. *)
type id = Basic.item_id [@@deriving to_yojson]

(** The type of the price of the items.*)
type price = Basic.item_price [@@deriving to_yojson]

(** The type of the unique name of the items.*)
type name = Basic.item_name [@@deriving to_yojson]

(** The user id of the seller of item.*)
type seller = Basic.user_id [@@deriving to_yojson]

(** The user id of the buyer of item.*)
type buyer = Basic.user_id [@@deriving to_yojson]

(** Represents a type of transaction. *)
type t = {id : id; price : price; name : name; 
          seller : seller; buyer: buyer}  [@@deriving to_yojson]

(** [new_trans id price name seller buyer] is a transaction 
    with fields corrseponding to the arguments. *)
val new_trans : id ->  price -> name -> seller -> buyer -> t

(** [from_json j] is the transaction represented by the json [j] *)
val from_json : Yojson.Basic.t -> t

