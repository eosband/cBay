open Basic
open Yojson.Basic.Util


type id = Basic.item_id [@@deriving to_yojson]

type price = Basic.item_price [@@deriving to_yojson]

type name = Basic.item_name [@@deriving to_yojson]

type seller = Basic.user_id [@@deriving to_yojson]

type buyer = Basic.user_id [@@deriving to_yojson]

exception InvalidItem of Basic.reason

type t = {
  id : id; 
  price : price; 
  name : name; 
  seller : seller; 
  buyer: buyer
}[@@deriving to_yojson]

let new_trans id price name seller buyer =
  {id = id; price = price; name = name; seller = seller; buyer = buyer}

let from_json j = {
  id = j |> member "id" |> to_int;
  price = j |> member "price" |> to_float;
  name =  j |> member "name" |> to_string;
  seller = j |> member "seller" |> to_string;
  buyer = j |> member "buyer" |> to_string
}
[@@coverage off]