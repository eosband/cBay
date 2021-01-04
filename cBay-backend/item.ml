
open Basic
open Offer
open Yojson.Basic.Util

type id = Basic.item_id[@@deriving to_yojson]

type price = Basic.item_price[@@deriving to_yojson]

type name = Basic.item_name[@@deriving to_yojson]

type category = Basic.item_category[@@deriving to_yojson]

type description = Basic.item_description[@@deriving to_yojson]

type seller = Basic.user_id[@@deriving to_yojson]

exception InvalidItem of Basic.reason

type t = {
  id : id; 
  price : price; 
  name : name; 
  category : category;
  description : description; 
  seller : seller; 
  offers : Offer.t list
}[@@deriving to_yojson]


let new_item id price name category description seller =
  {id = id; price = price; name = name; category = category; 
   description = description; seller = seller; offers = []}

let highest_offer item =
  let rec highest_offer_tr (offers : Offer.t list) (acc : float) = 
    match offers with 
    | [] -> acc
    | h :: t when h.price > acc -> highest_offer_tr t h.price 
    | h :: t -> highest_offer_tr t acc 
  in highest_offer_tr item.offers 0.0

let from_json j = {
  id = j |> member "id" |> to_int;
  price = j |> member "price" |> to_float;
  name = j |> member "name" |> to_string;
  category = j |> member "category" |> to_string;
  description = j |> member "description" |> to_string;
  seller = j |> member "seller" |> to_string;
  offers = j |> member "offers" |> to_list |> List.map Offer.from_json;
}
[@@coverage off]