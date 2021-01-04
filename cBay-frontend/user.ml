open Basic

type id = Basic.user_id[@@deriving to_yojson]

type password = Basic.user_password[@@deriving to_yojson]

type item_id = Basic.item_id[@@deriving to_yojson]


exception InvalidUser of Basic.reason


type t = {
  id : id; 
  password : password; 
  listed : Basic.item_id list
}[@@deriving to_yojson] 

let new_user id password =
  {id = id; password = password; listed = []}
