(** Class to handle client functionality as the middleman between main and the 
    server *)

open Item
open User
open Transaction
open Offer
open Lwt
open Cohttp
open Cohttp_lwt_unix
open Yojson
open Yojson.Basic.Util

(** The abstract type to represent the marketplace. *)
type t = unit

type response = bool * string

exception DataError of string
exception ServerError of string

let base_url = "http://35.245.220.250/api/"
(* let base_url = "http://localhost:8000/api/" *)

(** [make_json lst] is the json string respresentation of [lst].
    Requires: [lst] is a non-empty list of [string * string] tuples.
    Example: [make_json [("name","eric")]] is [{\n"name" : "eric"\n}] *)
let make_json lst =
  let string_from_pair (a, b) = 
    Printf.sprintf {|"%s" : "%s"|} a b
  in 
  let rec make_json_r acc = function
    | [] -> failwith "make_json precondition violated"
    | [x] -> acc ^ string_from_pair x ^ "\n}"
    | x :: y -> make_json_r (acc ^ string_from_pair x ^ ",\n") y
  in make_json_r "{\n" lst

(** [json_string_of_list lst] is a valid json string representation of [lst] *)
let json_string_of_list lst = 
  let lst = List.map (fun s -> "\"" ^ s ^ "\"") lst in
  "[" ^ String.concat "," lst ^ "]"

(** [make_post path json_string] makes a [POST] request to [base_url ^ path] 
    and passes along [json_string] as body, then returns a tuple [(code, body)]
    where [code] is the status code of the response and [body] is the 
    response body. *)
let make_post path json_string = 
  let post_body = Cohttp_lwt.Body.of_string json_string in
  let body =
    Client.post ~body:post_body 
      (Uri.of_string (base_url ^ path)) >>= 
    fun (resp, body) -> body |> Cohttp_lwt.Body.to_string >|= fun body ->
    let code = resp |> Response.status |> Code.code_of_status in
    code, body
  in Lwt_main.run body

(** [make_get path] makes a [GET] request to [base_url ^ path], then returns a 
    tuple [(code, body)] where [code] is the status code of the response and 
    [body] is the response body. *)
let make_get path = 
  let body =
    Client.get (Uri.of_string (base_url ^ path)) >>= 
    fun (resp, body) -> body |> Cohttp_lwt.Body.to_string >|= fun body ->
    let code = resp |> Response.status |> Code.code_of_status in
    code, body
  in Lwt_main.run body

(** [server_error_msg code msg] is string error message of the form 
    [Server code [code]: [msg]] *)
let server_error_msg code msg = 
  "Server error " ^ string_of_int code ^ ": " ^ msg

(** [error_msg msg] is a string error message of with [msg] *)
let error_msg msg = "Error: " ^ msg

(** [data_error msg] raises [DataError (error_msg msg)]. *)
let data_error msg = 
  raise (DataError (error_msg msg))

(** [server_error msg] raises [ServerError (error_msg msg)]. *)
let server_error msg = 
  raise (ServerError (error_msg msg))

(** [data_error_lst lst] is a string error message of the form [[msg]] 
    where [msg] is the string associated with key ["error"] in [lst] *)
let data_error_lst lst = 
  let msg = lst |> List.assoc "error" |> to_string in
  data_error msg

(** [data_from_post path json_string] makes a [POST] request with path
    [path] and json_string [json_string] and then handles the response according
    to the following rules:
    1) Tries ot return the json associated with [data] in the [POST] response
    2) If the body of the response could be read but the ["success"] key had a 
        value of [false], then raises a [ServerError]
    3) If the body of the response could not be read or does not contain
        a key ["success"] or ["data"], raises a [ServerError]
*)
let data_from_post path json_string = 
  let code, body = make_post path json_string in
  try
    let lst = body |> Yojson.Basic.from_string |> to_assoc 
    in match List.assoc "success" lst |> to_bool with
    | true -> List.assoc "data" lst
    | false -> data_error_lst lst
  with 
  | _ -> server_error (server_error_msg code body)

(** [data_from_get path] is the same as [data_from_post path json_string] but
    without as a [POST] request and with no [json_string] parameter *)
let data_from_get path = 
  let code, body = make_get path in
  try
    let lst = body |> Yojson.Basic.from_string |> to_assoc 
    in match List.assoc "success" lst |> to_bool with
    | true -> List.assoc "data" lst
    | false -> data_error_lst lst
  with 
  | _ -> server_error (server_error_msg code body)

let connect () = 
  try ignore (data_from_get "marketplace"); true
  with _ -> false

let validate_username username = 
  let code, body = make_get ("account/validate/" ^ username) in
  try
    body 
    |> Yojson.Basic.from_string 
    |> to_assoc 
    |> List.assoc "success" 
    |> to_bool
  with 
  | _ -> server_error (server_error_msg code body)

let categories () = 
  try
    let data = data_from_get "marketplace/categories" in
    let categories_json = to_list data in
    List.map (fun x -> to_string x) categories_json
  with 
  | _ -> data_error "Categories data from server could not be read"

let sold_trans seller = 
  let url = "/marketplace/sellhist/" ^ seller in
  try
    let data = data_from_get url in
    data |> to_list |> List.map Transaction.from_json
  with
  | _ -> data_error "Transactions data from server could not be read"

let bought_trans buyer = 
  let url = "/marketplace/buyhist/" ^ buyer in
  try
    let data = data_from_get url in
    data |> to_list |> List.map Transaction.from_json
  with
  | _ -> data_error "Transactions data from server could not be read"

let all_trans user_id = 
  let url = "/marketplace/allhist/" ^ user_id in
  try
    let data = data_from_get url in
    data |> to_list |> List.map Transaction.from_json
  with
  | _ -> data_error "Transactions data from server could not be read"

let find_item item_id = 
  let url = "marketplace/finditem/" ^ string_of_int item_id in
  try
    let data = data_from_get url in
    data |> Item.from_json
  with
    Type_error _ -> data_error "Could not read item from server data"

let get_items_of_cat categories = 
  let catlist = json_string_of_list categories in
  let json_string = {|{"categories" :|} ^ catlist ^ "}" in
  try
    let data = data_from_post "marketplace/categories" json_string in
    data |> to_list |> List.map Item.from_json
  with
    _ -> data_error "Could not read items from categories"

let get_items_of_user (user : User.t) = 
  let url = "marketplace/items/" ^ user.id in
  try
    let data = data_from_get url in
    data |> to_list |> List.map Item.from_json
  with
    _ -> data_error "Could not read items from user"

let get_offers_of_user (user : User.t) = 
  let url = "marketplace/offers/" ^ user.id in
  try
    let data = data_from_get url in
    let offers = 
      data |> member "offers" |> to_list |> List.map Offer.from_json in
    let items = 
      data |> member "items" |> to_list |> List.map Item.from_json in
    (offers, items)
  with
    _ -> data_error "Could not read offers from user"

let sell_item item = 
  let json_string = item 
                    |> Item.to_yojson
                    |> Yojson.Safe.to_basic 
                    |> Yojson.Basic.pretty_to_string 
  in 
  let data = data_from_post "marketplace/sell" json_string in
  let item_id = data |> member "item_id" |> to_int in
  item_id

let buy_item item_id user_id =
  let json_string = 
    Printf.sprintf {|{ "item_id" : %d, "user_id" : "%s" }|} item_id user_id
  in 
  let data = data_from_post "marketplace/buy" json_string in
  try
    let trans = data |> member "transaction" |> Transaction.from_json in
    trans
  with
    _ -> data_error "Could not read transaction data from server."

let make_offer offer = 
  let json_string = offer 
                    |> Offer.to_yojson
                    |> Yojson.Safe.to_basic 
                    |> Yojson.Basic.pretty_to_string 
  in let data = data_from_post "marketplace/offer" json_string in
  try
    let offer_id = data |> member "offer_id" |> to_string in
    offer_id
  with
    _ -> data_error "Could not read offer id data from server."

let accept_offer offer_id user_id = 
  let json_string = make_json [("offer_id", offer_id); ("seller", user_id)] in
  let data = data_from_post "marketplace/offer/accept" json_string in
  try
    let trans = data |> member "transaction" |> Transaction.from_json in
    trans
  with
    _ -> data_error "Could not read transaction data from server."

let decline_offer offer_id user_id = 
  let json_string = make_json [("offer_id", offer_id); ("seller", user_id)] in
  ignore (data_from_post "marketplace/offer/decline" json_string)


let create_user (user : User.t) = 
  let username = user.id in
  let password = user.password in
  let json_string = 
    make_json [("username", username); ("password", password)] in
  try
    ignore (data_from_post "account/create" json_string)
  with
    _ -> data_error "Could not create account wtih given credentials."


let authenticate_user (user : User.t) =
  let username = user.id in
  let password = user.password in
  let json_string = 
    make_json [("username", username); ("password", password)] in
  try
    let _ = data_from_post "account/authenticate" json_string in
    true
  with
  | DataError _ | ServerError _ -> false
