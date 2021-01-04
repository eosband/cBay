open Transaction
open Yojson.Basic.Util

type t = Transaction.t list [@@deriving to_yojson]

exception InvalidId


let transactions_from_json j = 
  j |> member "transactions" |> to_list |> List.map Transaction.from_json
[@@coverage off]

let empty_trans_state () = []

let add_transaction (transactions : t) (trans : Transaction.t) = 
  trans :: transactions

let get_trans_by_seller (transactions : t) (seller : Transaction.seller) = 
  let rec trans_by_seller_tr (trans : t) seller acc = 
    match trans with 
    | [] -> List.rev acc
    | h::t when h.seller = seller -> trans_by_seller_tr t seller (h :: acc)
    | h::t -> trans_by_seller_tr t seller acc
  in trans_by_seller_tr transactions seller []

let get_trans_by_buyer (transactions : t) (buyer : Transaction.buyer) = 
  let rec trans_by_buyer_tr trans buyer acc = 
    match trans with 
    | [] -> List.rev acc
    | h::t when h.buyer = buyer -> trans_by_buyer_tr t buyer (h :: acc)
    | h::t -> trans_by_buyer_tr t buyer acc
  in trans_by_buyer_tr transactions buyer []

let rec find_trans (transactions : t) (id : Transaction.id) = 
  match transactions with 
  | [] -> raise InvalidId
  | h :: t when h.id = id -> h
  | h :: t -> find_trans t id 
