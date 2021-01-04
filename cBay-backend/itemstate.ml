open Item 
open Yojson.Basic.Util

type t = {items: Item.t list; counter: int}  [@@deriving to_yojson]

exception InvalidId

let items_from_json j = 
  let item_list = j |> member "items" |> to_list |> List.map Item.from_json in
  let counter = j |> member "counter" |> to_int in
  {items = item_list; counter = counter}
[@@coverage off]

let empty_item_state () = {items = []; counter = 0}

let get_counter (items : t) = items.counter

let get_item_categories (items : t) = 
  List.map (fun item -> item.category) items.items
  |> List.sort_uniq compare

let get_items (items : t) = List.map (fun item -> item.id) items.items

let get_item_prices (items : t) = List.map (fun item -> item.price) items.items

let get_items_by_cat (items : t) (cat : Item.category) =
  let rec items_by_category_tr items cat acc = 
    match items with 
    | [] -> List.rev acc
    | h :: t when h.category = cat -> items_by_category_tr t cat (h :: acc)
    | h :: t -> items_by_category_tr t cat acc
  in items_by_category_tr items.items cat []

let remove_item (items : t) (item_id : Item.id) = 
  let rec remove_item_tr items counter id acc = 
    match items with 
    | [] -> raise InvalidId
    | h ::t when h.id = id -> {items = (List.rev acc) @ t; counter = counter} 
    | h :: t -> remove_item_tr t counter id (h :: acc)
  in remove_item_tr items.items items.counter item_id []

let add_item (items : t) (new_item : Item.t) = 
  {items = new_item :: items.items; counter = items.counter + 1} 

let find_item (items : t) (item_id : Item.id)= 
  let rec find_item_tr lst item_id =  
    match lst with 
    | [] -> raise InvalidId
    | h :: t when h.id = item_id -> h
    | h :: t -> find_item_tr t item_id 
  in find_item_tr items.items item_id 

let add_offer_to_item (items : t) (item : Item.t) (offer : Offer.t) =
  let new_item = {item with offers = offer :: item.offers} in 
  let rec offer_tr (lst: Item.t list) counter item id acc  = 
    match lst with 
    | [] -> failwith "impossible"
    | h :: t when h.id = id -> {items  = List.rev (item :: acc) @ t; 
                                counter = counter} 
    | h :: t -> offer_tr t counter item id (h :: acc)
  in offer_tr items.items items.counter new_item new_item.id [] 

(** [remove item offer] is the item with [offer] removed from the list of offers
    corresponding to [offer]
    Requires: 
    [item] is a valid item, and 
    [offer] is a valid offer type *)
let remove (item : Item.t) (offer : Offer.t) = 
  let rec remove_tr 
      (lst : Offer.t list) 
      (offer : Offer.t) 
      (acc : Offer.t list) = 
    match lst with 
    | [] -> failwith "remove"
    | h :: t when h = offer -> List.rev acc @ t 
    | h :: t -> remove_tr t offer (h :: acc)
  in {item with offers = remove_tr item.offers offer []}

let remove_offer_from_item (items : t) (item : Item.t) (offer : Offer.t) =
  let rec offer_tr (lst : Item.t list) counter item id acc = 
    match lst with 
    | [] -> failwith "invalid item"
    | h :: t when h.id = id -> {items  = List.rev (remove h offer :: acc) @ t; 
                                counter = counter} 
    | h :: t -> offer_tr t counter item id (h :: acc)
  in offer_tr items.items items.counter item item.id [] 