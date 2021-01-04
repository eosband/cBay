open User
open Itemstate
open Yojson.Basic.Util


type t = User.t list [@key "users"][@@deriving to_yojson]

exception UserIdTaken

exception InvalidId


let users_of_json j = {
  id = j |> member "id" |> to_string;
  password = j |> member "password" |> to_string;
  listed = j |> member "listed" |> to_list |> List.map to_int;
}
[@@coverage off]

let users_from_json j = 
  j |> member "users" |> to_list |> List.map users_of_json
[@@coverage off]

let empty_user_state () = []

let get_users (users : t) = List.map (fun user -> user.id) users

let rec get_user (users : t) (user_id : User.id) = 
  match users with 
  | [] -> raise InvalidId
  | h :: t when h.id = user_id -> h
  | _ :: t -> get_user t user_id

(** [user_equals user1 user2] is true when user2 has the same id and password
    as user1, and false otherwise. *)
let user_equals (user1 : User.t) (user2 : User.t) : bool = 
  user1.id = user2.id && user1.password = user2.password

let exists_user (users : t) (user : User.t) = 
  List.mem user users

let exists_username (users : t) (user_id : User.id) =   
  let usernames_list = List.map (fun user -> user.id) users in
  List.mem user_id usernames_list

let rec get_items (users : t) (user : User.id) =
  match users with 
  | [] -> failwith ""
  | h :: t when h.id = user -> h.listed
  | h :: t  -> get_items t user

let add_user (users : t) (user : User.t) = 
  if exists_username users user.id then raise UserIdTaken 
  else user :: users

let remove_user (users: t) (user : User.t) =
  if exists_user users user = false 
  then raise InvalidId  (** IS THIS OK??? *)
  else List.filter (fun u -> u != user) users

let add_item_to_user (users : t) (user_id : User.id) (item_id : Item.id) =
  let user = get_user users user_id in 
  let new_user = {id = user.id; 
                  password = user.password; 
                  listed = item_id :: user.listed} in
  add_user (remove_user users user) new_user

(**[remove_id id lst acc] is the new list of item ids after [id] is removed 
   from [lst]
   Requires: 
    [id is a valid item id], 
    [lst] is a valid list of item ids, and
    [acc] is an empty list.
   Raises: ItemState.InvalidId if [id] is not in [lst]*)
let rec remove_id (id : Item.id) (lst : Basic.item_id list) acc = 
  match lst with
  | [] -> raise Itemstate.InvalidId
  | h :: t when h = id -> (List.rev acc) @ t 
  | h :: t -> remove_id id t (h :: acc) 

let remove_item_from_user (users : t) (user_id : User.id) (item_id : Item.id) =
  let user = get_user users user_id in 
  let ids = user.listed in 
  let new_ids = remove_id item_id ids [] in 
  let new_user = {id = user.id; password = user.password; listed = new_ids} in
  add_user (remove_user users user) new_user
