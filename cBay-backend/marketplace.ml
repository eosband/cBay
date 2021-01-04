open Item 
open User 
open Transaction
open Offer 
open Itemstate
open Userstate 
open Transactionstate

type t = { item_state: Itemstate.t;
           user_state: Userstate.t;  
           trans_state : Transactionstate.t }
[@@deriving to_yojson]

exception InvalidOfferEntered

let new_marketplace () = { 
  item_state = empty_item_state (); 
  user_state = empty_user_state ();
  trans_state = empty_trans_state ()
} 

let read_marketplace () = {
  item_state = items_from_json (Yojson.Basic.from_file "items.json");
  user_state = users_from_json (Yojson.Basic.from_file "users.json");
  trans_state = transactions_from_json 
      (Yojson.Basic.from_file "transactions.json")
}

let read_test_marketplace () = {
  item_state = items_from_json (Yojson.Basic.from_file "item_sample.json");
  user_state = users_from_json (Yojson.Basic.from_file "user_sample.json");
  trans_state = transactions_from_json 
      (Yojson.Basic.from_file "transaction_sample.json")
}

let get_item_state t = t.item_state

let get_user_state t = t.user_state

let get_trans_state t = t.trans_state

let validate_username (mp : t) (username : User.id) = 
  not (Userstate.exists_username mp.user_state username)

let categories (mp : t) = 
  Itemstate.get_item_categories (mp.item_state)

let sold_trans (mp : t) (seller : Transaction.seller) = 
  Transactionstate.get_trans_by_seller (mp.trans_state) seller  

let bought_trans (mp : t) (buyer : Transaction.buyer) = 
  Transactionstate.get_trans_by_buyer (mp.trans_state) buyer 

let find_item (mp : t) (id : Item.id) = 
  Itemstate.find_item mp.item_state id 

let find_trans (mp : t) (id : Transaction.id) =
  Transactionstate.find_trans mp.trans_state id 

let get_items_by_user (mp : t) (username : User.id) = 
  let ids = Userstate.get_items (mp.user_state) username in 
  let rec get_my_items_tr items ids acc =  
    match ids with 
    | [] -> List.rev acc
    | h :: t -> get_my_items_tr items t ((Itemstate.find_item items h) :: acc)
  in get_my_items_tr mp.item_state ids [] 

let get_items_of_cat (mp : t) (cat_lst : Item.category list) = 
  let rec get_items_tr items lst acc = 
    match lst with
    | [] -> acc
    | h :: t -> 
      get_items_tr items t ((Itemstate.get_items_by_cat items h) @ acc)
  in get_items_tr mp.item_state cat_lst []

let sell_item (mp : t) (item : Item.t) = 
  let user = Userstate.get_user (mp.user_state) (item.seller) in 
  let items = mp.item_state in 
  let users = mp.user_state in 
  let item_id = Itemstate.get_counter mp.item_state + 1 in
  let item' = {item with id = item_id} in 
  let mp' = {item_state = Itemstate.add_item items item'; 
             user_state = Userstate.add_item_to_user users user.id item'.id;
             trans_state = mp.trans_state}
  in item_id, mp'

let buy_item (mp : t) (id : Item.id) (buyer : Basic.user_id) = 
  let items = mp.item_state in
  let users= mp.user_state in 
  let trans = mp.trans_state in 
  let item = Itemstate.find_item items id in 
  let user = item.seller in
  let tran = Transaction.new_trans id item.price item.name user buyer in 
  tran, {item_state= Itemstate.remove_item items id; 
         user_state= Userstate.remove_item_from_user users user id; 
         trans_state = Transactionstate.add_transaction trans tran}

let make_offer (mp : t) offer = 
  let items = mp.item_state in
  let item_id = offer.item_id in 
  let item = Itemstate.find_item items item_id in 
  let offer_length = List.length item.offers in 
  let offer_id = 
    string_of_int item_id ^ "-" ^ string_of_int (offer_length + 1) in 
  let offer' = {offer with id = offer_id} in
  let new_items = Itemstate.add_offer_to_item items item offer' in 
  let mp' = {item_state = new_items; user_state = mp.user_state; 
             trans_state = mp.trans_state} in
  offer_id, mp'

let find_offer (mp : t) (id : Offer.id) = 
  let lst = String.split_on_char '-' id in 
  let item_id =  int_of_string (List.nth lst 0) in 
  let items = mp.item_state in 
  let item = Itemstate.find_item items item_id in 
  let rec find_offer_tr (offers : Offer.t list) id = 
    match offers with 
    | [] -> raise InvalidOfferEntered
    | h :: t when h.id = id  -> h 
    | h :: t -> find_offer_tr t id
  in find_offer_tr item.offers id 

let accept_offer (mp : t) (id : Offer.id)  (seller : Basic.user_id) =
  let offer = find_offer mp id in 
  let items = mp.item_state in
  let users= mp.user_state in 
  let trans = mp.trans_state in 
  let item_id = offer.item_id in 
  let item = Itemstate.find_item items item_id in  
  let user = item.seller in 
  let tran = 
    Transaction.new_trans item_id offer.price item.name seller offer.buyer in 
  let mp' = {item_state = Itemstate.remove_item items item_id; 
             user_state = Userstate.remove_item_from_user users user item_id; 
             trans_state = Transactionstate.add_transaction trans tran} in
  tran, mp'

let decline_offer (mp : t) (id : Offer.id) =
  let offer = find_offer mp id in 
  let items = mp.item_state in
  let users= mp.user_state in 
  let trans = mp.trans_state in 
  let item_id = offer.item_id in 
  let item = Itemstate.find_item items item_id in  
  {item_state = Itemstate.remove_offer_from_item items item offer; 
   user_state = users; 
   trans_state = trans} 

let get_offers_by_user mp username =
  let items = mp.item_state.items in
  let rec by_item offs item item_offs items_items = 
    match offs with 
    | [] -> item_offs, items_items
    | h :: t when h.buyer = username -> by_item t item (h :: item_offs) 
                                          (item :: items_items)
    | h :: t -> by_item t item item_offs items_items
  in 
  let rec all items' all_offs all_items = 
    match items' with 
    | [] -> all_offs, all_items 
    | h :: t -> 
      let (h_offers,h_items) = by_item h.offers h [] [] in 
      all t (h_offers @ all_offs) (h_items @ all_items)
  in all items [] []

let create_user (mp : t) user = 
  {item_state = mp.item_state;
   user_state = add_user mp.user_state user;
   trans_state = mp.trans_state}

let authenticate_user (mp : t) (user : User.t) = 
  let users = mp.user_state in 
  Userstate.exists_user users user

(** [print_json ys out form] prints the yojson basic form of [ys] with "{
    [form] ... }" to the file [out] *)
let print_json ys out form = 
  output_string (open_out out) ("{\n" ^ "\"" ^ form ^ "\" :\n" ^  
                                (Yojson.Basic.pretty_to_string 
                                   (Yojson.Safe.to_basic (ys))) ^ "\n}")

(**[print_item json ys out] prints the yojson basic form of [ys] to the file
   [out] *)
let print_item_json ys out = 
  Yojson.Basic.pretty_to_channel (open_out out) (Yojson.Safe.to_basic ys)

let write_marketplace mp  = 
  print_json (Userstate.to_yojson mp.user_state) "users.json" "users";
  print_item_json (Itemstate.to_yojson mp.item_state) "items.json";
  print_json (Transactionstate.to_yojson mp.trans_state) "transactions.json" 
    "transactions";
  flush_all()
