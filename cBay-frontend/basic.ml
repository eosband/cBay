

type item_id = int[@key "item id"][@@deriving to_yojson]

type item_price = float[@@deriving to_yojson]

type item_name = string[@@deriving to_yojson]

type item_category = string[@@deriving to_yojson]

type item_description = string[@@deriving to_yojson]

type user_id = string[@@deriving to_yojson]

type user_password = string[@@deriving to_yojson]

type reason = string
