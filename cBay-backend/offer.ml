open Yojson.Basic.Util
open Basic


exception InvalidOffer of Basic.reason

type price = Basic.item_price[@@deriving to_yojson]

type buyer = Basic.user_id[@@deriving to_yojson]

type id = string[@@deriving to_yojson]

type t = {
  buyer : buyer;
  price : price; 
  item_id : Basic.item_id[@key "item id"];
  id : id
}
[@@deriving to_yojson]

let new_offer buyer price item_id id = 
  {buyer = buyer; price = price; item_id = item_id; id = id}

let from_json j = {
  buyer = j |> member "buyer" |> to_string;
  price = j |> member "price" |> to_float;
  item_id = j |> member "item id" |> to_int;
  id = j |> member "id" |> to_string;
}
[@@coverage off]
