open Lwt
open Cohttp
open Cohttp_lwt_unix
open Yojson
open Yojson.Basic.Util
open Marketplace

let success_response = {|{"success": true,"data": |}
let invalid_response = {|{"success": false, "error": |}

let _ = Cohttp_lwt_unix__.Debug.activate_debug ()

(** [string_of_list lst] is a valid json string of a list. *)
let string_of_list lst = 
  "[" ^ String.concat "," lst ^ "]"

(** [string_of_string_list lst] is a valid json string of a string list. *)
let string_of_str_list lst = 
  let lst = List.map (fun s -> "\"" ^ s ^ "\"") lst in
  string_of_list lst

(** [item_to_string item] converts [item] to a string representing the json aka. 
    Yojson.Basic.t type of the corresponding item. *)
let item_to_string (item : Item.t) : string = 
  item 
  |> Item.to_yojson
  |> Yojson.Safe.to_basic 
  |> Yojson.Basic.pretty_to_string

(** [offer_to_string item] converts [offer] to a string representing the json 
    aka. Yojson.Basic.t type of the corresponding offer. *)
let offer_to_string (offer : Offer.t) : string = 
  offer
  |> Offer.to_yojson
  |> Yojson.Safe.to_basic 
  |> Yojson.Basic.pretty_to_string

(** [transaction_to_string transaction] converts [transaction] to a string 
    representing the json aka. Yojson.Basic.t type of the corresponding 
    transaction. *)
let transaction_to_string (trans : Transaction.t) : string = 
  trans 
  |> Transaction.to_yojson
  |> Yojson.Safe.to_basic 
  |> Yojson.Basic.pretty_to_string

(** [extract_endpoint uri] converts an endpoint into a list strings representing
    its contents.
    Ex. "/api/marketplace/categories" -> ["api", "marketplace", "categories"] *)
let extract_endpoint uri = 
  let filter_uri = 
    List.filter (fun x -> x <> "" && x <> "api") (String.split_on_char '/' uri) 
  in match filter_uri with 
  | [] -> []
  | h :: t -> t

let create body = 
  let j = Yojson.Basic.from_string body in
  let mp = Marketplace.read_marketplace () in 
  let username  = j |> member "username" |> to_string in
  let password = j |> member "password" |> to_string in
  let user = User.new_user username password in 
  match Marketplace.validate_username mp username with 
  | true ->  begin
      write_marketplace (Marketplace.create_user mp user); 
      success_response ^ {|"Account created successfully."}|}, 200
    end
  | false -> invalid_response ^ {|"Username already taken."}|}, 406

let authenticate body = 
  let j = Yojson.Basic.from_string body in
  let mp = read_marketplace () in
  let username = j |> member "username" |> to_string in
  let password = j |> member "password" |> to_string in
  let user = User.new_user username password in 
  match Marketplace.authenticate_user mp user with 
  | true -> success_response ^ {|"Authenticated."}|}, 200
  | false -> invalid_response ^ {|"Invalid password."}|},  406

let validate_username username body = 
  let mp = read_marketplace () in
  match Marketplace.validate_username mp username with
  | false -> invalid_response ^ {|"Invalid username."}|}, 406
  | true -> success_response ^ {|"Valid username."}|}, 200

let get_marketplace body = 
  let users = Yojson.Basic.(to_string (from_file "users.json")) in
  let items = Yojson.Basic.(to_string (from_file "items.json")) in
  let trans = Yojson.Basic.(to_string (from_file "transactions.json")) in
  (success_response ^ "[" ^ users ^ ", " ^ items ^ ", " ^ trans ^ "]}"), 200

let reset_marketplace body = 
  let test_mp = read_test_marketplace () in 
  write_marketplace test_mp;
  get_marketplace ""

let buy_item body = 
  let j = Yojson.Basic.from_string body in  
  let mp = read_marketplace () in 
  let item_id = j |> member "item_id" |> to_int in
  let user = j |> member "user_id" |> to_string in
  let trans, mp' = Marketplace.buy_item mp item_id user in
  try 
    write_marketplace mp'; 
    let s_trans = transaction_to_string trans in
    success_response ^ {|{"transaction":|} ^ s_trans ^ "}}", 200
  with Itemstate.InvalidId -> invalid_response ^ {|"Invalid item id."}|}, 406

let sell_item body = 
  let j = Yojson.Basic.from_string body in  
  let mp = read_marketplace () in 
  let price = j |> member "price" |> to_float in
  let name = j |> member "name" |> to_string in
  let category = j |> member "category" |> to_string in
  let description = j |> member "description" |> to_string in
  let seller = j |> member "seller" |> to_string in
  let item =  Item.new_item ~-1 price name category description seller in
  let item_id, mp' = Marketplace.sell_item mp item in
  try 
    write_marketplace mp'; 
    success_response ^ {|{"item_id": |} ^ string_of_int item_id ^ "}}", 200
  with 
    Itemstate.InvalidId -> 
    invalid_response ^ {|"Item could not be listed."}|}, 500

let categories body = 
  let mp = read_marketplace () in 
  let cats = Marketplace.categories mp in
  success_response ^ string_of_str_list cats ^ "}", 200

let get_items_of_categories body =
  let j = Yojson.Basic.from_string body in  
  let mp = read_marketplace () in 
  let cats = 
    j |> member "categories" |> to_list |> List.map (fun j -> to_string j) in
  let item_of_cats = 
    Marketplace.get_items_of_cat mp cats |> List.map item_to_string in
  write_marketplace mp;
  success_response ^ string_of_list item_of_cats ^ "}", 200

let offer body =
  let j = Yojson.Basic.from_string body in  
  let mp = read_marketplace () in 
  let buyer = j |> member "buyer" |> to_string in
  let price = j |> member "price" |> to_float in
  let item_id = j |> member "item id" |> to_int in 
  let off = Offer.new_offer buyer price item_id "" in 
  let off_id, mp' = Marketplace.make_offer mp off in
  try 
    write_marketplace mp';
    success_response ^ {|{"offer_id":"|} ^ off_id ^ {|"}}|}, 200
  with 
    Itemstate.InvalidId -> invalid_response ^ {|"Invalid item id."}|}, 406

let accept_offer body =
  let j = Yojson.Basic.from_string body in  
  let mp = read_marketplace () in 
  let offer_id = j |> member "offer_id" |> to_string in
  let seller =  j |> member "seller" |> to_string in 
  try 
    let trans, mp' = Marketplace.accept_offer mp offer_id seller in 
    write_marketplace mp';
    let s_trans = transaction_to_string trans in
    success_response ^ {|{"transaction":|} ^ s_trans ^ "}}", 200
  with x -> match x with 
    | Itemstate.InvalidId | Marketplace.InvalidOfferEntered -> 
      invalid_response ^ {|"Invalid offer id '|} ^ offer_id ^ {|'}."}|}, 406
    | _ -> failwith "impossible"

let decline_offer body =
  let j = Yojson.Basic.from_string body in  
  let mp = read_marketplace () in 
  let offer_id = j |> member "offer_id" |> to_string in
  let seller =  j |> member "seller" |> to_string in 
  try 
    let item_id = 
      match String.split_on_char '-' offer_id with 
      | x :: _ -> int_of_string x
      | _ -> ~-1
    in
    let item = Marketplace.find_item mp item_id in 
    if item.seller = seller 
    then 
      let mp = Marketplace.decline_offer mp offer_id in 
      write_marketplace mp;
      success_response ^ {|"Offer declined."}|}, 200
    else 
      invalid_response ^ {|"Invalid item id."}|}, 406
  with
  | Itemstate.InvalidId | Marketplace.InvalidOfferEntered -> 
    invalid_response ^ {|"Invalid offer id '|} ^ offer_id ^ {|'}."}|}, 406
  | _ -> failwith "decline offer impossible"

let get_offers_by_user username body = 
  let mp = read_marketplace () in 
  match Marketplace.validate_username mp username with 
  | true -> invalid_response ^ {|"Invalid username."}|}, 406
  | false -> 
    let offers, items = Marketplace.get_offers_by_user mp username in 
    let offers_lst = offers |> List.map offer_to_string |> string_of_list in
    let items_lst = items |> List.map item_to_string |> string_of_list in
    let resp = 
      Printf.sprintf {|{"offers": %s, "items": %s } }|} offers_lst items_lst in
    success_response ^ resp, 200

let get_items_by_user username body =
  let mp = read_marketplace () in 
  match Marketplace.validate_username mp username with 
  | true -> invalid_response ^ {|"Invalid username."}|}, 406
  | false -> begin
      let items = 
        Marketplace.get_items_by_user mp username |> List.map item_to_string in 
      success_response ^ string_of_list items ^ "}", 200
    end

let get_item_by_id item_id body =   
  let mp = read_marketplace () in 
  try 
    let item = 
      item_id |> int_of_string |> Marketplace.find_item mp |> item_to_string in
    success_response ^ item ^ "}", 200
  with 
  | Itemstate.InvalidId -> invalid_response ^ {|"Invalid item id."}|}, 406

let get_buy_hist username body = 
  let mp = read_marketplace () in 
  match Marketplace.validate_username mp username with 
  | true -> invalid_response ^ {|"Invalid username."}|}, 500
  | false -> begin
      let trans = 
        Marketplace.bought_trans mp username |> List.map transaction_to_string in 
      success_response ^ string_of_list trans ^ "}", 200
    end

let get_sell_hist username body = 
  let mp = read_marketplace () in 
  match Marketplace.validate_username mp username with 
  | true -> invalid_response ^ {|"Invalid username."}|}, 406
  | false -> begin
      let trans = 
        Marketplace.sold_trans mp username |> List.map transaction_to_string in 
      success_response ^ string_of_list trans ^ "}", 406
    end

let get_all_hist username body = 
  let mp = read_marketplace () in
  match Marketplace.validate_username mp username with 
  | true -> invalid_response ^ {|"Invalid username."}|}, 406
  | false -> begin
      let sold_trans = Marketplace.sold_trans mp username in
      let bought_trans = Marketplace.bought_trans mp username in
      let trans = List.map transaction_to_string (sold_trans @ bought_trans) in
      success_response ^ string_of_list trans ^ "}", 406
    end

(** [router uri meth] unpacks the request information and delegates
    what marketplace function to execute. Returns a response with successful or 
    unsuccessful information. *)
let router uri meth = 
  let endpoint = uri |> extract_endpoint in
  print_endline (string_of_list endpoint); 
  print_endline uri;
  match endpoint with 
  | ["marketplace"] -> begin
      match meth with 
      | "GET" -> get_marketplace
      | _ -> fun _ -> "Invalid request.", 404
    end
  | "account" :: ["create"] -> begin
      match meth with
      | "POST" -> create
      | _ -> fun _ -> "Invalid request.", 404
    end
  | "account" :: "validate":: [username] -> begin
      match meth with
      | "GET" -> validate_username username
      | _ -> fun _ -> "Invalid request.", 404
    end
  | "account" :: ["authenticate"] -> begin
      match meth with
      | "POST" -> authenticate
      | _ -> fun _ -> "Invalid request.", 404
    end
  | "marketplace" :: ["buy"] -> begin 
      match meth with 
      | "POST" -> buy_item
      | _ -> fun _ -> "Invalid request.", 404
    end 
  | "marketplace" :: ["sell"] -> begin 
      match meth with 
      | "POST" -> sell_item
      | _ -> fun _ -> "Invalid request.", 404
    end
  | "marketplace" :: ["categories"] -> begin
      match meth with
      | "GET" -> categories
      | "POST" -> get_items_of_categories
      | _ -> fun _ -> "Invalid request.", 404
    end
  | "marketplace" :: ["offer"] -> begin
      match meth with
      | "POST" -> offer
      | _ -> fun _ -> "Invalid request.", 404
    end
  | "marketplace" :: "offer" :: ["accept"] -> begin
      match meth with
      | "POST" -> accept_offer
      | _ -> fun _ -> "Invalid request.", 404
    end
  | "marketplace" :: "offer" :: ["decline"] -> begin
      match meth with
      | "POST" -> decline_offer
      | _ -> fun _ -> "Invalid request.", 404
    end
  | "marketplace" :: "offers" :: [username] -> begin
      match meth with
      | "GET" -> get_offers_by_user username
      | _ -> fun _ -> "Invalid request.", 404
    end
  | "marketplace" :: "items" :: [username] -> begin
      match meth with
      | "GET" -> get_items_by_user username
      | _ -> fun _ -> "Invalid request.", 404
    end
  | "marketplace" :: "finditem" :: [item_id] -> begin
      match meth with 
      | "GET" -> get_item_by_id item_id
      | _ -> fun _ -> "Invalid request.", 404
    end
  | "marketplace" :: "buyhist" :: [username] -> begin
      match meth with
      | "GET" -> get_buy_hist username
      | _ -> fun _ -> "Invalid request.", 404
    end
  | "marketplace" :: "sellhist" :: [username] -> begin
      match meth with
      | "GET" -> get_sell_hist username
      | _ -> fun _ -> "Invalid request.", 404
    end
  | "marketplace" :: "allhist" :: [username] -> begin
      match meth with
      | "GET" -> get_all_hist username
      | _ -> fun _ -> "Invalid request.", 404
    end
  | _ ->
    fun _ -> Printf.sprintf "Uri: %s\nMethod: %s\n" uri meth, 404

(** [server ()] starts the server on port 8000 of machine. Handles requests 
    into the server. *)
let server () =
  let callback _conn req body =
    let uri = req |> Request.uri |> Uri.to_string in
    let meth = req |> Request.meth |> Code.string_of_method in
    body |> Cohttp_lwt.Body.to_string >|= (router uri meth) 
    >>= fun (body, status_code) -> 
    Server.respond_string ~status:(`Code status_code) ~body:body ()
  in
  print_endline "Server running on port 8000...";
  Server.create ~mode:(`TCP (`Port 8000)) (Server.make ~callback ())

let _ = Lwt_main.run (server ())