(** 
   A module with functions that are executed upon requests by the server to
   carry out changes to the marketplace.
 **)

(** [get_marketplace body] returns a success response with marketplace 
    information or failure repsonse if marketplace is unable to be retrieved. 
    Ex.
    \{ "success": true, "data": <marketplace info> \}, 200
    \{ "success": false, "error": "Error while retrieving marketplace."\}, 406 
*)
val get_marketplace : string -> string * int

(** [reset_marketplace body] returns a success response with test marketplace 
    information and resets database to contain information from the test 
    marketplace.
    FOR ADMINISTRATIVE TESTING PURPOSES ONLY
    Ex.
    \{ "success": true, "data": <test marketplace info>\}, 200
    \{ "success": false, "error": "Error while resetting marketplace."\}, 406 *)
val reset_marketplace : string -> string * int

(** [create body] returns a success response if user is successfully created 
    from information in [body] or a failure response if user is unable to be 
    created.
    Ex.
    \{ "success": true, "data": <username> \}, 200
    \{ "success": false, "error": "Username already taken."\}, 406 *)
val create : string -> string * int

(** [authenticate body] returns a success response if user is successfully 
    authenticated from information in [body] or a failure repsonse if user is 
    unable to be authenticated.
    Ex.
    \{ "success": true, "data": <username> \}, 200
    \{ "success": false, "error": "Invalid username/password combo."\}, 406 *)
val authenticate : string -> string * int


(** [validate_username username body] returns a success response if [username] 
    exists in marketplace and failure response otherwise.
    Ex.
    \{ "success": true, "data": "Valid username."\}, 200
    \{ "success": false, "error": "Invalid username."\}, 406 *)
val validate_username : string -> string -> string * int

(** [buy_item body] returns a success response if item is bought from 
    information in [body] or a failure repsonse if not.
    Ex.
    \{"success": true, "data": ["user": <username>, "item_id":<item_id> ]\}, 200
    \{"success": false, "error": "Invalid item id"\}, 406 *)
val buy_item : string -> string * int

(** [sell_item body] returns a success response if item is listed from 
    information in [body] or a failure repsonse if not.
    Ex.
    \{ "success": true, "data": []\}, 200
    \{ "success": false, "error": <error message> \}, 500 *)
val sell_item : string -> string * int

(** [categories body] returns a success response with categories
    in the marketplace.
    Ex.
    \{ "success": true, "data": [<category>, <category>] \}, 200 *)
val categories : string -> string * int

(** [items_of_categories body] returns a success response with items of 
    categories in [body]. Returns an empty list if there are no items of the 
    categories provided in the marketplace.
    Ex.
    \{ "success": true, "data": [<item>, <item>, <item>,...]\}, 200 *)
val get_items_of_categories : string -> string * int

(** [offer body] returns a success response if offer based on information in 
    [body] was initiated successfully and a failure response otherwise.
    Ex.
    \{ "success": true, "data": "Offer initiated."\}, 200
    \{ "success": false, "error": "Invalid item id."\}, 406
    \{ "success": false, "error": "Invalid offer entered."\}, 406 *)
val offer : string -> string * int

(** [accept_offer body] returns a success response if offer based on information 
    in [body] was accepted and failure response otherwise.
    Ex.
    \{ "success": true, "data": "Offer accepted."\}, 200
    \{ "success": false, "error": "Invalid item id."\}, 406
    \{ "success": false, "error": "Invalid offer entered."\}, 406 *)
val accept_offer : string -> string * int

(** [decline_offer body] returns a success response if offer based on 
    information in [body] was declined and failure response otherwise.
    Ex.
    \{ "success": true, "data": "Offer declined."\}, 200
    \{ "success": false, "error": "Invalid item id."\}, 406
    \{ "success": false, "error": "Invalid offer entered."\}, 406 *)
val decline_offer : string -> string * int

(** [get_offers_by_user username body] returns a success response with offers 
    that a user has made and a list of the item information with it and a
     failure response otherwise.
    Ex.
    \{ "success": true, "data": \{ "offers": 
    [<offer, <offer>, <offer>,... ], 
    "items":[<item>, <item>, <item>,... ]\}\}, 200
    \{ "success": false, "error": "Invalid username."\}, 401 *)
val get_offers_by_user : string -> string -> string * int

(** [get_items_by_user username body] returns a success response with items of
    [username] and failure response otherwise.
    Ex.
    \{ "success": true, "data": [<item>, <item>, <item>,... ]\}, 200
    \{ "success": false, "error": "Invalid username."\}, 401 *)
val get_items_by_user : string -> string -> string * int

(** [get_item_by_id item_id body] returns a success response with the item
    that has [item_id] and a failure response otherwise.
    Ex.
    \{ "success": true, "data": [<item>]\}, 200
    \{ "success": false, "error": "Invalid item id."\}, 406 *)
val get_item_by_id : string -> string -> string * int

(** [get_buy_hist username body] returns a success response with a list of 
    transaction for which the [username] was the buyer and a failure 
    response otherwise.
    Ex.
    \{ "success": true, "data": [<transaction>, <transaction>,...]\}, 200
    \{ "success": false, "error": "Invalid username."\}, 406 *)
val get_buy_hist : string -> string -> string * int

(** [get_sell_hist username body] returns a success response with a list of 
    transaction for which the [username] was the seller and a failure 
    response otherwise.
    Ex.
    \{ "success": true, "data": [<transaction>, <transaction>,...]\}, 200
    \{ "success": false, "error": "Invalid username."\}, 406 *)
val get_sell_hist : string -> string -> string * int

(** [get_all_hist username body] returns a success response with a list of 
    transaction for which the [username] was involved and a failure 
    response otherwise.
    Ex.
    \{ "success": true, "data": [<transaction>, <transaction>,...]\}, 200
    \{ "success": false, "error": "Invalid username."\}, 406 *)
val get_all_hist : string -> string -> string * int

(** [router uri meth] unpacks the request information and delegates
    what marketplace function to execute. Returns a success or failure response
    with an error code. *)
val router : string -> string -> string -> string * int