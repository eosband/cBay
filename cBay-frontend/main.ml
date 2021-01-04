open Yojson.Basic.Util
open Item
open Offer
open User
open Command
open ANSITerminal
open PrintBox
open Client
module B = PrintBox
open Progress

let invalid_command_msg = 
  "We are sorry, but we could not understand the command you entered. \
   Please try again with a valid command."
let empty_command_msg = 
  "Sorry, but your command was empty. Please enter a valid command and try \
   again."
let unknown_msg = 
  "Sorry, but you seemed to have entered an unknown commmand. Please try again."
let logout_msg = 
  "[logout]. Well, we're sorry to see you go. We hope you had fun in the \
   Marketplace! Come back soon :)"
let help_msg =
  "Marketplace commands: \n \
   \t menu/help: Display this menu list \n\
   \t view: Initiate query to view listings \n\
   \t buy: Initiate query to buy an item \n\
   \t sell: Initiate query to sell an item \n\
   \t offer: Initiate query to make an offer \n\
   Administrative commands:
   \t cancel: Cancel any previous query and return to the user prompt. \n\
   \t logout: Logout of your account, marketplace stays open \n\
   \t quit: Quit the marketplace\
  "

(** An exception for when the user's input could not be understood. *)
exception InvalidCommand of string

(** The state of this interface *)
type state = {
  current_user : User.t;
}

(** [colors_arr] is an array of PrintBox foreground style colors to be used in 
    displaying tables *)
let colors_arr = 
  Style.([|Green; Blue; Magenta; Red; Yellow|])
  |> Array.map (fun x -> Style.fg_color x) 

(** [colors_arr_ansi] is an array of ANSITerminal style colors to be used in 
    displaying categories *)
let colors_arr_ansi = 
  [|green; blue; magenta; red; yellow|]

(** [print_color style str] is a unit that prints to the ANSITerminal 
    [str] in style [style]. Note that the carriage will be moved to a newline 
    after the print, so it effectively behaves like [Stdlib.print_endline] 
    but with [style]. *)
let print_color (style : ANSITerminal.style) (str : string) = 
  print_string [style] (str ^ "\n")

(** [print_bcolor style str] is a unit that behaves exacty as 
    [print_color style str] but with bold text as well. *)
let print_bcolor (style : ANSITerminal.style) (str : string) = 
  print_string [Bold; style] (str ^ "\n")

(** [main0] is a simple mutable variable that will be updated with 
    [main] later. Here so that other functions can call [main]. *)
let main0 = ref (fun () -> print_bcolor red "main0 not updated")

(** [prompt_user0] is a simple mutable variable that will be updated with 
    [prompt_user] later. Here so that other functions can call [prompt_user].*)
let prompt_user0 = ref (fun st -> print_bcolor red "prompt_user0 not updated")

(** [print_error str] is a unit that will print [str] to the console with 
    error formatting. *)
let print_error (str : string) = print_color yellow str

(** [print_warning str] is a unit that will print [str] to the console with 
    warning formatting. *)
let print_warning (str : string) = print_color yellow str

(** [print_help] is a unit that will print the help message to the console
    with help formatting *)
let print_help () = print_bcolor white help_msg

(** [print_info str] is a unit that will print [str] to the console with 
    info formatting. *)
let print_info (str : string) = print_bcolor white str

(** [print_info str] is a unit that will print [str] to the console with 
    info formatting. *)
let print_prompt (str : string) = print_color red str

(** [print_success str] is a unit that will print [str] to the console with 
    success formatting. *)
let print_success (str : string) = print_color green str

(** [print_carat ()] is a unit that will print a single carat to the 
    console, without a newline at the end. *)
let print_carat () = print_string [Bold; white] "> "

(** [string_of_price x] is a string representation of [x] as a price. *)
let string_of_price x =
  Format.asprintf "$%.2f" (x +. 0.0001)

(** [print_logo ()] prints the trademarked cBay logo to the terminal. *)
let print_logo () : unit = 
  let read_file channel = 
    let lines = ref [] in 
    try
      while true; do
        lines := input_line channel :: !lines
      done; !lines
    with
    | _ -> List.rev !lines in 
  let print_bbcolor (style : ANSITerminal.style) (str : string) = 
    print_string [Bold; Background Black; style] (str ^ "\n") in 
  let _ = 
    List.map (fun s -> print_bbcolor red s) (read_file (open_in "cbay.txt")) in 
  print_endline "\n"


(** [read_onecarat st] is the string containing whatever the user inputted to 
    the console, as specified by read_line (), after printing a carat to the 
    console SO LONG AS no escape sequence was entered by the user.
    If the user entered the force quit or cancel sequences, [read_onecarat st] 
    will call the appropriate functions and redirect the user appropriately. *)
let read_onecarat st = 
  let force_quit () = 
    let msg = "[force quit] Thank you for safely shutting down. \
               We hope you come back soon!"
    in print_success msg;
    exit 0
  in let cancel () = 
       print_warning "[cancel] You have cancelled your request.";
       (!prompt_user0) st; "cancel impossible"
  in print_carat ();
  match String.trim (read_line ()) with 
  | ":qa!"-> force_quit ()
  | "cancel" -> cancel ()
  | s -> s

(** [read st] is [read_onecarat st] but with one additional carat printed
    before the user prompt. *)
let read st = 
  print_string [Bold; white] ">";
  read_onecarat st

(** [get_item_id st] will prompt the user to enter an [item_id] and validates
    their response. Will repeatedly ask the user to enter an [item_id]
    with helpful error messages along the way until a valid [item_id] is 
    entered, in which case that is what this function evaluates to. *)
let rec get_item_id st = 
  print_prompt "Please enter the Item ID of the product you would like to buy:";
  let s = read st in
  try
    match int_of_string s with 
    | x when x < 0 -> begin
        let msg = "Sorry, but you must enter a positive item id. \
                   Please try again." 
        in print_error msg; 
        get_item_id st
      end
    | x -> x 
  with 
  | _ -> begin
      let msg = Printf.sprintf 
          "Sorry, but item id '%s' was invalid. Please enter a \
           valid integer id." s
      in print_error msg; get_item_id st
    end

(** [get_name st] will prompt the user to enter a product name until they 
    enter a valid name, at which point this function evaluates to that name. *)
let rec get_name st = 
  print_prompt "Please enter a name for the product you would like to sell: ";
  let name = read st in
  match name with 
  | "" -> print_error "Please enter a non-empty item name"; get_name st
  | _ -> name

(** [get_name st] will prompt the user to enter a [price] until they 
    enter a valid price, at which point this function evaluates to that 
    price. *)
let rec get_price st = 
  print_prompt "Please enter your desired price: ";
  let price = read st in 
  try 
    match float_of_string price with 
    | x when x <= 0.0 -> begin
        print_error "Price must be a positive number"; 
        get_price st
      end
    | x -> x
  with
  | _ -> begin
      let msg = Printf.sprintf 
          "Price '%s' could not be interpreted. \
           Please enter a valid price." price
      in print_error msg; get_price st
    end

(** [is_float s] is [true] if [s] can be converted to a float, and [false]
    otherwise. *)
let is_float s =
  try ignore (float_of_string s); true
  with _ -> false

(** [is_int s] is [true] if [s] can be converted to a int, and [false]
    otherwise. *)
let is_int s =
  try ignore (int_of_string s); true
  with _ -> false

(** [get_category st] will prompt the user to enter a [category] until they
    enter a valid one, at which point this function evaluates to that value. *)
let rec get_category st = 
  print_prompt "Please enter the category for the product you would like to \
                sell: ";
  let category = read st in
  match category with 
  | "" -> print_error "Error: category name cannot be empty"; get_category st
  | s when is_float s -> begin
      print_error "Error: category name cannot be a number"; 
      get_category st
    end
  | _ -> category

(** [get_description st] will prompt the user to enter a [description] until 
    they enter a valid one, at which point this function evaluates to that
    value. *)
let rec get_description st = 
  let msg = "Please enter a description for the product you would like to sell:"
  in print_prompt msg;
  let description = read st in
  match description with 
  | "" -> print_error "Error: description cannot be empty"; get_description st
  | _ -> description

(** [print_item_without_id item] is a unit that will print all the fields
    of an [item] except for its [id]. *)
let print_item_without_id (item : Item.t) = 
  let str = "Name: " ^ item.name ^ "\n"
            ^ "Category: " ^ item.category ^ "\n"
            ^ "Asking price: " ^ string_of_price item.price ^ "\n"
            ^ "Description: " ^ item.description ^ "\n"
  in print_color black str

(** [print_item item] is unit that will print all the fields of an [item],
    including [id].*)
let print_item (item : Item.t) = 
  let s_id = Printf.sprintf "ID: %d" item.id in 
  print_color black s_id;
  print_item_without_id item

(** [get_item st] will ask the user to select an item, and then will ask the
    user to confirm the item queried is the one they intended. Will repeat
    this process until the user accepts the item, at which point will return
    the [item]. *)
let rec get_item st = 
  let id = get_item_id st in 
  try 
    let item = Client.find_item id in
    print_info "\nThis is the item you have selected:";
    print_item item;
    print_prompt "Is this the correct item? (y/n)";
    match read st with 
    | "y" -> item
    | _ -> print_info "Sorry, let's try again."; get_item st
  with 
  | ServerError msg -> print_error msg; get_item st
  | DataError msg -> print_error msg; get_item st
  | _ -> begin
      let msg = Printf.sprintf 
          "Sorry, but item id '%d' did not correspond \
           to a valid id. Please try again." id
      in print_error msg;
      get_item st
    end

(** [make_offer st] will direct the user through the functionality of making an 
    offer in the marketplace. Once one has been made, it returns the updated 
    [state]. *)
let rec make_offer st =
  let item = get_item st in
  try
    let price = get_price st in 
    let off = Offer.new_offer st.current_user.id price item.id "" in
    let s_price = string_of_price price in
    let msg = Printf.sprintf 
        "Confirm: You would like to make an offer for the item above at \
         price %s. (y/n)" s_price
    in print_prompt msg;
    match read st with
    | "y" -> begin
        let offer_id = Client.make_offer off in
        let msg = Printf.sprintf 
            "[offer] Congrats! Offer no. %s has successfully \
             been made!" offer_id
        in print_success msg;
        st
      end
    | _ -> print_info "Sorry, feel free to try again."; st
  with
  | ServerError msg -> print_error msg; st
  | DataError msg -> print_error msg; st
  | _ -> begin 
      let msg = "Sorry, but we could not execute your offer of this item. \
                 Please try again later."
      in print_error msg; st
    end

(** [accept_offer st offer_id] accepts offer with id [offer_id] if possible. *)
let accept_offer st (offer_id : string) = 
  let trans = Client.accept_offer offer_id st.current_user.id in 
  let str_price = string_of_price trans.price in 
  let msg = Printf.sprintf 
      "[accept offer] You have accepted offer no. %s of item '%s' to user \
       %s at price %s."  offer_id trans.name trans.buyer str_price
  in print_success msg; st

(** [decline_offer st offer_id] declines offer with id [offer_id] if possible.*)
let decline_offer st (offer_id : string) = 
  Client.decline_offer offer_id st.current_user.id; 
  let msg = 
    Printf.sprintf "[decline offer] Offer no. %s has been declined." offer_id
  in print_success msg; st

(** [make_offer st] will direct the user through the functionality of making an 
    offer in the marketplace. Once one has been made, it returns the updated 
    [state]. *)
let rec offer st : state = 
  let print_offer_help () = 
    print_info "These are your offer options:";
    print_info "\tnew: follow instructions to make an offer on an item";
    print_info "\taccept/decline [offer_id]: accept/decline offer with id \
                [offer_id]. If you do not know the offer_id, you can
                view the offers on an item through 'view' and then entering
                the [item_id].";
  in print_prompt "Please enter your offer query. Type 'help' to see all \
                   options.";
  try
    match read st with
    | "help" -> print_offer_help (); offer st
    | "new" -> make_offer st
    | s when String.sub s 0 6 = "accept" -> begin
        accept_offer st (String.sub s 7 (String.length s - 7))
      end
    | s when String.sub s 0 7 = "decline" -> begin
        decline_offer st (String.sub s 8 (String.length s - 8))
      end
    | s -> raise (InvalidCommand s)
  with
  | ServerError msg | DataError msg -> print_error msg; st
  | InvalidCommand s -> begin
      print_error ("We could not understand '" ^ s ^ "'. Please try again."); 
      offer st
    end
  | _ -> begin
      print_error "Sorry, but your offer command could not be interpreted. \
                   Please try again."; 
      offer st
    end

(** [buy st] will direct the user through the functionality of buying an 
    item in the marketplace. Once one has been bought, it returns the updated 
    [state]. *)
let rec buy st =  
  let item = get_item st in 
  try 
    let s_price = string_of_price item.price in
    let msg = Printf.sprintf "Confirm: You would like to buy the item above at \
                              its price %s. (y/n)" s_price
    in print_prompt msg;
    match read st with
    | "y" -> begin
        let trans = Client.buy_item item.id st.current_user.id in
        let str = Printf.sprintf 
            "[buy] Congrats! Your purchase of '%s' has \been made as \
             transaction no. %d." trans.name trans.id 
        in print_success str; st
      end
    | _ -> print_info "Sorry, feel free to try again."; buy st
  with 
  | ServerError msg -> print_error msg; st
  | DataError msg -> print_error msg; st
  | _ -> begin
      let msg = "Sorry, but we could not execute your buy of this item. Please \ 
      try again later." 
      in print_error msg; st
    end

(** [sell st] will direct the user through the functionality of selling an 
    item in the marketplace. Once one has been listed, it returns the updated 
    [state]. *)
let rec sell st = 
  let id = -1 in 
  let name = get_name st in 
  let price = get_price st in 
  let category = get_category st in 
  let desc = get_description st in 
  let item = Item.new_item id price name category desc st.current_user.id in
  try
    print_info "\nThis is the item you have listed to sell:";
    print_item_without_id item;
    print_prompt "Are these values correct? (y/n)";
    match read st with 
    | "y" -> begin
        let item_id = Client.sell_item item in
        let msg = Printf.sprintf
            "[sell] Congrats! Your item '%s' has been \
             listed as id no. %d." name item_id
        in print_success msg; st
      end
    | _ -> print_info "Sorry, feel free to try again."; st
  with 
  | ServerError msg -> print_error msg; st
  | DataError msg -> print_error msg; st
  | _ -> begin
      let msg = "Sorry, but we could not list your item for selling. Please \
                 try again later." 
      in print_error msg; st
    end

(** [parse_categories str] is the list of [item] categories that was in [str]
    but separated by spaces. *)
let parse_categories str : Item.category list  = 
  let rec remove_empty 
      (acc : Item.category list) 
      (lst : string list) : Item.category list =
    match lst with
    | [] -> List.rev acc
    | h :: t when h = "" -> remove_empty acc t
    | h :: t -> remove_empty (h :: acc) t 
  in str |> String.split_on_char ' ' |> remove_empty []

(** [get_index lst elem] is the integer index of [elem] in [lst], or [0] if
    [elem] is not in [lst].*)
let get_index lst elem = 
  let rec get_index_r n = function
    | [] -> 0
    | h :: t when h = elem -> n
    | h :: t -> get_index_r (n + 1) t
  in get_index_r 0 lst

(** [cut_description description] is [description] but with newline characters
    ['\n'] inserted every certain number of characters (currently set at 50). *)
let cut_description description = 
  let cutoff = 50 in
  let rec cut_r acc desc = 
    match String.length desc with 
    | x when x <= cutoff -> acc ^ desc
    | x -> begin
        let rest = String.sub desc cutoff (x - cutoff) in
        let start = acc ^ "\n" ^ String.sub desc 0 cutoff in
        cut_r start rest
      end
  in cut_r "" description

(** [apply_header_style] is a function to apply header style to a string.
    Intended for use with printing tables. *)
let apply_header_style = 
  fun x -> text_with_style Style.(set_bold true @@ fg_color Black) x

(** [arr_item item categories] is an array of all the item fields in 
    category converted to PrintBox style with their categories color coded
    by prevalence in [categories] list. *)
let arr_item (item : Item.t) (categories : Item.category list) = 
  let get_style category = 
    let i = get_index categories category in
    Array.get colors_arr (i mod 5) 
  in 
  let id = string_of_int item.id |> text in 
  let cat = item.category |> text_with_style (get_style item.category) in 
  let name = item.name |> text in 
  let description = item.description |> cut_description |> text in 
  let price = item.price |> string_of_price |> text in 
  let highest_offer = Item.highest_offer item |> string_of_price |> text in 
  [ id; cat; name; description; price; highest_offer ]

(** [print_items items categories] prints all items in [items] and colors
    their category name by its prevalence in [categories] list. The table is 
    sorted by category, and each category name is a different color. *)
let print_items (items : Item.t list) (categories : Item.category list) : unit = 
  let items = List.rev items in
  let headers = List.map apply_header_style
      ["ID"; "Category"; "Name"; "Description"; "Price"; "Highest offer"]
  in 
  let table = 
    headers :: (List.map (fun item -> arr_item item categories) items)
  in frame @@ grid_l table |> PrintBox_text.output stdout

(** [display_by_categories st s] first validates all the categories in string s
    (i.e. removes and informs the user if an invalid category was specified)
    and then returns a unit that will print the table matching the query. 
    If no valid categories were specified by the user, then instead of a table
    it will print an error message informing the user of that. *)
let display_by_categories st s = 
  try
    let all = Client.categories () in
    let rec valid_categories acc = function
      | h :: t when not (List.mem h all) -> begin
          let msg = Printf.sprintf 
              "Error: category '%s' is not a valid category. Ignoring..." h
          in print_warning msg; 
          valid_categories acc t 
        end
      | h :: t -> valid_categories (h :: acc) t
      | [] -> acc
    in 
    let cs = s |> parse_categories |> valid_categories [] in
    match cs with 
    | [] -> begin
        print_error "Sorry, but there were no valid categories in your request."
      end
    | _ -> print_items (Client.get_items_of_cat cs) cs
  with
  | ServerError msg | DataError msg -> print_error msg

(** [print_all_items (s] prints all items in the marketplace. *)
let print_all_items () = 
  let categories = Client.categories () in
  let items = Client.get_items_of_cat categories in 
  print_items items categories

(** [get_prog_bar total] gets a progress bar with total amount [total]. *)
let get_prog_bar (total : int) =
  let total = Int64.of_int (total) in
  let bar = Progress.counter 
      ~total:total ~mode:`UTF8 ~message:"Retrieving from server..." () in
  fst (Progress.start bar)

(** [print_all_categories categories] is a unit that will print all the 
    categories in [categories].*)
let print_categories_lst (categories : Item.category list) = 
  let disp_bar = get_prog_bar (List.length categories) in
  let get_style category = 
    let i = get_index categories category in
    Array.get colors_arr_ansi (i mod 5) 
  in
  let rec print_categories_r count = function
    | [] -> print_endline ""
    | h :: t -> begin
        disp_bar (Int64.of_int count);
        let num = Client.get_items_of_cat [h] |> List.length in
        let cat_count = Printf.sprintf " (%d)" num in
        print_string [get_style h] ("\t" ^ h); print_color black cat_count;
        print_categories_r (count + 1) t
      end
  in match categories with
  | [] -> print_error "[no categories found]"
  | _ -> begin
      print_bcolor black "\nCategories:";
      print_categories_r 1 categories
    end

(** [arr_offer offer item categories] is a PrintBox styled array of all
    the information on [offer], as styled by [item] and [categories]. *)
let arr_offer 
    (offer : Offer.t) 
    (item : Item.t) 
    (categories : Item.category list) = 
  let get_style category = 
    let i = get_index categories category in
    Array.get colors_arr (i mod 5)
  in 
  let offer_id = offer.id |> text in
  let item_name = item.name |> text in 
  let cat = item.category |> text_with_style (get_style item.category) in 
  let buyer = offer.buyer |> text_with_style Style.(fg_color Blue) in 
  let seller = item.seller |> text in 
  let asking = item.price |> string_of_price |> text in 
  let offer = offer.price |> string_of_price |> text in 
  let status = "pending" |> text_with_style Style.(fg_color Yellow) in 
  [offer_id; item_name; cat; seller; buyer; asking; offer; status ] 

(** [print_offers user_id offers_items] prints all of the offers in 
    [offers_items] to the terminal, and colors them according to [user_id]'s
    role in the offer (i.e. as a buyer or seller). *)
let print_offers 
    (user_id : User.id) 
    (offers_items : Offer.t list * Item.t list) = 
  let categories = Client.categories () in
  let rec list_offers acc = function
    | [], [] -> acc
    | h1 :: t1, h2 :: t2 -> 
      list_offers (arr_offer h1 h2 categories :: acc) (t1, t2)
    | _ -> failwith "print_offers precondition violated"
  in 
  let headers = List.map apply_header_style
      ["Offer ID"; " Name "; " Category "; " Seller "; " Buyer "; 
       " Asking price "; " Offered "; " Status "]
  in match offers_items with
  | [], [] -> 
    print_error "[There were no offers associated with the given query]"
  | _ -> begin
      let table = headers :: list_offers [] offers_items
      in frame @@ grid_l table |> PrintBox_text.output stdout
    end

(** [display_offers_of_user user] prints all offers made by [user]. *)
let display_offers_of_user (user : User.t) : unit = 
  Client.get_offers_of_user user |> print_offers user.id

(** [arr_item_with_offers item categories] is PrintBox styled 2d-array of the 
    given item, followed by each of its offers. *)
let arr_item_with_offers (item : Item.t) (categories : Item.category list) = 
  let arr_offer (offer : Offer.t) = 
    let id = offer.id |> text in 
    let buyer = offer.buyer |> text in 
    let price = offer.price |> string_of_price |> text in 
    let blank = "" |> text in 
    [blank; blank; blank; id; buyer; price]
  in 
  let item_headers = List.map apply_header_style
      ["ID"; "Category"; "Name"; "Description"; "Price"; "Highest offer"]
  in 
  let table1 = item_headers :: [arr_item item categories] in 
  let offer_headers = List.map apply_header_style
      [""; ""; ""; "Offer ID"; "Buyer"; "Price"]
  in 
  let table2 = 
    offer_headers :: List.map (fun offer -> arr_offer offer) item.offers
  in table1 @ table2

(** [display_items_of_user user] prints all items listed by [user]. *)
let display_items_of_user (user : User.t) : unit = 
  let items = Client.get_items_of_user user in
  match items with
  | [] -> print_error "[There were no items associated with this user]"
  | _ -> begin
      let categories = Client.categories () in
      let item_tbls = 
        List.map (fun x -> arr_item_with_offers x categories) items
      in 
      let table = List.fold_left (fun x acc -> x @ acc) [] item_tbls in 
      frame @@ grid_l table |> PrintBox_text.output stdout
    end

(** [display_item user s] prints the given item and all offers associated 
    with it given a user [user]. *)
let display_item (user : User.t) (item_id : int) : unit = 
  let item = Client.find_item item_id in
  let table = arr_item_with_offers item [item.category]
  in frame @@ grid_l table |> PrintBox_text.output stdout

(** [arr_trans user_id trans] is a PrintBox styled array of all
    information in [trans] styled according to [user_id]. *)
let arr_trans (user_id : User.id) (trans : Transaction.t)= 
  let userid_style = function
    | s when s = user_id -> text_with_style Style.(fg_color Blue) s
    | s -> text_with_style Style.default s
  in 
  let type_text (tr : Transaction.t) = 
    match tr with 
    | trans when trans.buyer = user_id -> 
      "bought" |> text_with_style Style.(fg_color Green)
    | _ -> 
      "sold" |> text_with_style Style.(fg_color Red)
  in 
  let item_id = trans.id |> string_of_int |> text in 
  let item_name = trans.name |> text in 
  let buyer = trans.buyer |> userid_style in 
  let seller = trans.seller |> userid_style in 
  let price = trans.price |> string_of_price |> text in 
  let trans_type = type_text trans in 
  [item_id; item_name; buyer; seller; price; trans_type]

(** [print_transactions user_id trans] prints to a fancy table all of the 
    transactions in [trans] and color codes them according to user_id's role
    in each transaction. *)
let print_transactions (user_id : User.id) (transactions : Transaction.t list) =
  let headers = List.map apply_header_style
      ["Item ID"; " Item name "; " Buyer "; " Seller "; " Price "; " Type " ]
  in match transactions with
  | [] -> 
    print_error "[There were no transactions associated with the given query]"
  | _ -> begin
      let table = 
        headers :: List.map (fun tr -> arr_trans user_id tr) transactions
      in frame @@ grid_l table |> PrintBox_text.output stdout
    end

(** [display_bought_trans user] displays all transactions that the user has
    made in which they were the buyer. *)
let display_bought_trans (user : User.t) : unit = 
  let trans = Client.bought_trans user.id in
  print_transactions user.id trans

(** [display_sold_trans user] displays all transactions that the user has
    made in which they were the seller. *)
let display_sold_trans (user : User.t) : unit = 
  let trans = Client.sold_trans user.id in
  print_transactions user.id trans

(** [display_all_trans user] displays all transactions that the user has made
    in which they were either the buyer or the seller. *)
let display_all_trans (user : User.t) : unit = 
  let trans = Client.all_trans user.id in
  print_transactions user.id trans

(** [print_view_help ()] displays a help message with all possible view
    query commands.  *)
let print_view_help () = 
  print_info "These are your view options:";
  print_info "\t[item_id]: view all offers on the item with id [item_id]";
  print_info "\tmy items: display all items you have listed";
  print_info "\tmy offers: display all of your pending offers";
  print_info "\ttransactions: display a history of all transactions";
  print_info "\tbought: display a history of all buy transactions";
  print_info "\tsold: display a history of all sell transactions";
  print_info "\t[cat1] [cat2] ...: display all items in categories \
              [cat1], [cat2], ...";
  print_info "\tcategories: display the list of all current item categories";
  print_info "\tall: display all items in the marketplace"

(** [view st] walks the user through all steps of viewing items in
    the marketplace, and returns the same [state] once complete. *)
let rec view st = 
  print_prompt "Please enter your view query. Type 'help' to see all \
                options.";
  try
    match read st with
    | "" -> print_error "Please enter at least one category."; view st
    | "help" -> print_view_help (); view st;
    | "categories" -> print_categories_lst (Client.categories ()); view st
    | "all" -> print_all_items (); st
    | "my items" -> display_items_of_user st.current_user; st
    | "my offers" -> display_offers_of_user st.current_user; st
    | "transactions" -> display_all_trans st.current_user; st
    | "bought" -> display_bought_trans st.current_user; st
    | "sold" -> display_sold_trans st.current_user; st
    | s when is_int s -> display_item st.current_user (int_of_string s); st 
    | s -> display_by_categories st s; st
  with
  | ServerError msg | DataError msg -> print_error msg; st

(** [menu ()] is a unit that will display the help menu *)
let menu () = print_help ()

(** [logout ()] will log the user out of the marketplace, save the current
    state back to json, and return the client to the main menu where they
    can login or create a new user as before. *)
let logout () =
  print_success "[logout command interpreted]";
  print_color red "Thank you for visiting the marketplace – hope to see you \
                   again soon! A new user can now create an account or log in!"

(** [quit ()] will quit the marketplace and save the current state back to 
    json. *)
let quit () =
  print_success "[quit command interpreted]";
  print_color red "Marketplace is now quitting... Goodbye!"; exit 0

(** [prompt_user st] will prompt the user for a command and delegate 
    which functions to call based on their response. *)
let rec prompt_user st =
  print_bcolor red "\nWhat would you like to do?";
  let response = read_onecarat st in
  try
    match parse response with 
    | Offer -> prompt_user (offer st)
    | Buy -> prompt_user (buy st)
    | View -> prompt_user (view st)
    | Sell -> prompt_user (sell st)
    | Menu -> menu (); prompt_user st
    | Logout -> logout (); !main0 ()
    | Quit -> quit ();
  with 
  | Empty -> print_error empty_command_msg; prompt_user st
  | Unknown -> print_error ("[" ^ response ^ "] " ^ unknown_msg); prompt_user st

(** [welcome_marketplace st] welcomes the user the marketplace, print
    the help message, and then prompt them for an input. *)
let welcome_marketplace (st : state) = 
  let msg = Printf.sprintf "Congratulations, %s, you have successfully entered \
                            the marketplace.\n" st.current_user.id
  in print_success msg; 
  menu (); prompt_user st

(** [login ()] walks the user through the steps necessary to log them
    into the marketplace. *)
let rec login () = 
  print_prompt "Please enter your username: ";
  print_carat ();
  let username = read_line () in
  print_prompt "Please enter your password: ";
  print_carat ();
  let password = read_line () in
  let user = User.new_user username password in
  try
    match Client.authenticate_user user with
    | true -> welcome_marketplace {current_user = user}
    | false -> print_error "Invalid username/password combination."
  with
  | ServerError msg -> print_error msg

(** [choose_username ()] is the [user_id] chosen by the user through a sequence
    of prompts. Ensures that [user_id] has not been taken in the marketplace
    already. *)
let rec choose_username () : User.id = 
  print_prompt "Enter a username: ";
  print_carat ();
  let username = read_line () in
  try
    match Client.validate_username username with
    | true -> username
    | false -> begin
        let msg = Printf.sprintf "Username '%s' already taken. Please try \
                                  again." username
        in print_error msg; 
        choose_username ()
      end
  with
  | ServerError msg -> print_error msg; choose_username ()

(** [choose_password ()] walks the user through the steps necessary to choose
    their password. *)
let rec choose_password () : User.password = 
  print_prompt "Enter a password: ";
  print_carat ();
  let password1 = read_line () in
  print_prompt "Please confirm password: ";
  print_carat ();
  let password2 = read_line () in
  match password1 = password2 with
  | true -> password1
  | false -> 
    print_error "Passwords do not match. Please try again."; choose_password ()

(** [make_new_account ()] walks the user through the steps necessary to make
    a new account in the marketplace. *)
let rec make_new_account () = 
  let msg = "Thank you for choosing to join Cornell MarketPlace. Please follow \
             the following prompts to create an account."
  in print_bcolor red msg;
  let username = choose_username () in
  let password = choose_password () in 
  let user = User.new_user username password in
  try 
    let _ = Client.create_user user in
    print_success "[User successfully created]";
    welcome_marketplace {current_user = user}
  with 
  | ServerError msg | DataError msg -> print_error msg

(** [print_progress_bar total n bar] prints a progress bar at different
    progresses until the counter [n] hits [total]. *)
let rec print_progress_bar (total : int) (n : int) bar = 
  match n with
  | x when x * 2 >= total -> ()
  | _ -> 
    bar (Int64.of_int n); Unix.sleepf 0.1; print_progress_bar total (n + 1) bar

(** [connect_to_server ()] attempts to connect to the server via client. If
    the connection is refused, or some other error is encountered, then it will 
    quit the application. *)
let connect_to_server () =
  print_endline "";
  let total = Int64.of_int 20 in
  let bar = Progress.counter 
      ~total:total ~mode:`UTF8 ~message:"Connecting to server..." () in
  let started = Progress.start bar in
  print_progress_bar (Int64.to_int total) 0 (fst started);
  print_endline "\n";
  match Client.connect () with 
  | true -> 
    print_info "[Connection to marketplace server successfully established]\n"
  | false -> begin
      let msg = "Connection to marketplace server could not be established. \
                 We apologize for this inconvenience, please try again later.\n"
      in print_error msg;
      exit 0;
    end

(** [main ()] is the entrypoint to the marketplace as a whole, where the 
    user can decide if they want to login, make a new user, or quit. *)
let main () =
  print_bcolor red "\n\nWelcome to Cornell MarketPlace!";
  connect_to_server ();
  print_logo ();
  let rec main_r () = 
    let msg = "\nPlease type 'login' to login, 'newuser' to create a new \
               account, or 'quit' to quit."
    in print_color red msg;
    print_carat ();
    match read_line () with
    | "login" -> 
      print_success "[login command interpreted]\n"; 
      login (); main_r ()
    | "newuser" -> 
      print_success "[new user command interpreted]\n"; 
      make_new_account (); 
      main_r ()
    | "quit" -> 
      quit ();
    | response -> 
      print_error ("[" ^ response ^ "] " ^ invalid_command_msg); main_r ()
  in main_r ()

(** Official OCaml entrypoint *)
let () = 
  let interrupt_msg = "\nThank you for choosing cBay. Please come again soon!"
  in 
  let redirect_interrupt = 
    fun x -> print_color red interrupt_msg; exit 0
  in Sys.(set_signal sigint (Signal_handle redirect_interrupt));
  main0 := main; 
  prompt_user0 := prompt_user; 
  main ()
