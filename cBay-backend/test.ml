open OUnit2
open Marketplace
open User
open Item
open Offer
open Transaction
open Userstate
open Itemstate
open Transactionstate

(** Test Plan: 
    cBay is thoroughly tested for correctness through unit testing, 
    integration testing, and end-to-end testing. 

    1. Unit testing:
    A majority of tests done - which can be found in this 
    file - involved unit testing. This meant taking the modules that make up the 
    functionality in our backend system and testing all the functions in the
    respective modules function specification. We did this module by module as 
    we composed modules to ensure that at all times, all modules we were 
    interfacing with would produce the expected functionality. Modules tested in 
    this manner were Marketplace, Itemstate, Userstate, Transactionstate, Offer, 
    User, Item, and Transaction. We unit tested all these modules through a 
    combination of Black box testing as well as Glass box testing - mainly to 
    ensure exceptions were being thrown when needed.

    It is important to note that the last module, we tested was purposefully
    Marketplace. The Marketplace module serves as the main functionality of 
    cBay, containing functions such as buy item, sell item, and make an offer. 
    When a function is called in Marketplace, Marketplace typically call 
    functions in Itemstate, Userstate, and Transactionstate. That being said, 
    before we tested Marketplace, we wanted to be certain that all modules the 
    produce the expected functionality seperately before using them together in 
    Marketplace. 

    2. Integration Testing
    cBay is composed of two systems - a frontend and a backend. The backend
    is meant to run on a server that any frontend client can communicate with.
    The module Mp_server represents the entry point into the server as well as
    handles performing operations and returning resulting success and failure
    responses. Because the output of all these functions are JSON responses, 
    rather than write unit tests, we performed integration tests with Postman by
    running the server locally and ensuring responses of endpoints sent to the
    server produced the correct result.

    This decision was made because testing Mp_server represents testing 
    communication between client and backend works as expected rather than 
    testing logic as all logic used Mp_server is already tested in underlying 
    modules such as Marketplace.

    This workflow involved implementing a "route" on our API specification, 
    deciding on GET/POST parameters and input, implementing the route in 
    Mp_server, then testing the correct success and failure response messages 
    were retrieved by Postman.

    3. End-to-End testing
    cBay's frontend system - and communication with the backend was tested
    through manual end-to-end testing. This methodology was selected with the 
    idea that should our modules, backend, and frontend be working correctly,
    users would be able to interact with our client and expect correct results 
    ensuring the moving pieces of frontend and backend were working. 

    This workflow involved deploying our backend on a Google VM intstance, 
    installing the frontend/client on all team members computers and interacting
    with the client to ensure correctness. When unexpected functionlity arose, 
    we isolated whether it was produced by our frontend or backend system.

*)

(** [cmp_set_like_lists lst1 lst2] compares two lists to see whether
    they are equivalent set-like lists.  That means checking two things.
    First, they must both be {i set-like}, meaning that they do not
    contain any duplicates.  Second, they must contain the same elements,
    though not necessarily in the same order. *)
let cmp_set_like_lists lst1 lst2 =
  let uniq1 = List.sort_uniq compare lst1 in
  let uniq2 = List.sort_uniq compare lst2 in
  List.length lst1 = List.length uniq1
  &&
  List.length lst2 = List.length uniq2
  &&
  uniq1 = uniq2

(** [pp_string s] pretty-prints string [s]. *)
let pp_string s = "\"" ^ s ^ "\""

(** [pp_list pp_elt lst] pretty-prints list [lst], using [pp_elt]
    to pretty-print each element of [lst]. *)
let pp_list pp_elt lst =
  let pp_elts lst =
    let rec loop n acc = function
      | [] -> acc
      | [h] -> acc ^ pp_elt h
      | h1 :: (h2 :: t as t') ->
        if n = 100 then acc ^ "..."  (* stop printing long list *)
        else loop (n + 1) (acc ^ (pp_elt h1) ^ "; ") t'
    in loop 0 "" lst
  in "[" ^ pp_elts lst ^ "]"

(* -------- tests for command ------- *)

let command_tests = [
]

(* -------- tests for item ------------*)

(* example item 1 *)
let talia_user_id : User.id = "talia"

let id_1 : Item.id = 10
let price_1: Item.price = 10.00
let name_1 : Item.name = "shirt"
let category_1 : Item.category = "clothes"
let description_1 : Item.description = "a pretty shirt"
let seller_1: Item.seller = talia_user_id
let offer_1 : Offer.t list = []

let item_1 = {id = 10; price = 10.00; name = "shirt"; 
              description = "a pretty shirt"; 
              category = "clothes";
              seller = talia_user_id;
              offers = []}

(** item_make_item_test name1 id price name category desc seller 
    expected_output] 
    test the creation of a new item type. *)
let item_make_item_test
    (name1 : string)
    (id : Item.id)
    (price : Item.price)
    (name : Item.name)
    (category : Item.category)
    (desc : Item.description)
    (seller : Item.seller)
    (expected_output : Item.t) : test =
  name1 >:: (fun _ ->
      assert_equal expected_output 
        (new_item id price name category desc seller))

let item_tests = [
  item_make_item_test "test item 1 was created" 
    id_1 price_1 name_1 category_1 description_1 seller_1 item_1;
]

(* --------- tests for user --------- *)


(* example user 1 *)
let id_1 : User.id = "talia"
let password_1 : User.password = "password123"
let user_1 :  User.t = {id = "talia"; password = "password123"; listed = []}

(* example user 2 *)
let id_2 : User.id = "gus"
let password_2 : User.password = "ruff"
let user_2 :  User.t = {id = "gus"; password = "ruff"; listed = []}


(** [user_new_user_test name id password expected_output] 
    test the creation of a new user type. *)
let user_new_user_test
    (name : string)
    (id : User.id)
    (password : User.password)
    (expected_output : User.t) : test =
  name >:: (fun _ ->
      assert_equal expected_output (new_user id password))

let user_tests = [
  user_new_user_test "test user talia was created" id_1 password_1 user_1;
  user_new_user_test "test user gus was created" id_2 password_2 user_2;
]

(* –––––––– tests for offer ––––––––––– *)

let buyer_1 = user_1.id
let price_1 = 10.41
let item_id_1 = item_1.id
let offer_1 : Offer.t = {buyer = "talia"; price = 10.41; item_id = 10; 
                         id = "10-1"}

(** [new_offer_test name buyer price item_id expected_output] 
    test the creation of a new offer type. *)
let new_offer_test 
    (name : string)
    (buyer : Offer.buyer)
    (price : Offer.price)
    (item_id : Item.id) 
    (id: string)
    (expected_output : Offer.t): test = 
  name >:: (fun _ ->
      assert_equal expected_output (new_offer buyer price item_id id))

let offer_tests = [
  new_offer_test "test new offer by talia was created" 
    buyer_1 price_1 item_id_1 "10-1" offer_1; 
]

(*--------------------------userstate tests--------------------------------*)

(** [get_users_test name users exp_output] is a helepr function to test
    retrieval of usernames from [users]] *)
let get_users_test 
    (name : string)
    (users : Userstate.t)
    (exp_output : User.id list): test= 
  name >:: (fun _ ->
      assert_equal ~cmp:cmp_set_like_lists ~printer:(pp_list pp_string)  
        exp_output (get_users users))

(** [get_user_test name users user exp_output] is a helepr function to test
    retrieval of a user from [users]. *)
let get_user_test 
    (name : string)
    (users : Userstate.t)
    (username : User.id)
    (exp_output : User.t): test= 
  name >:: (fun _ ->
      assert_equal exp_output (get_user users username))       

(** [my_items_test name users username exp_output] is a helepr function to test
    retrieval of a list of item ids of [username] in [users]. *)
let get_items_test 
    (name : string)
    (users : Userstate.t)
    (username : User.id)
    (exp_output : Basic.item_id list): test= 
  name >:: (fun _ ->
      assert_equal exp_output (Userstate.get_items users username))   

let init_user_state = empty_user_state ()

let user_one = {
  id = "Tedi Mitiku";
  password = "tiff";
  listed = [];
}

let user_two = {
  id = "Talia Attar";
  password = "tough";
  listed = [];
}

(** adding a user *)
let user_state_one = add_user init_user_state user_one
let user_state_two  = add_user user_state_one user_two

let item = {id = 10; price = 10.00; name = "shirt"; 
            description = "a pretty shirt"; 
            category = "clothes";
            seller = talia_user_id;
            offers = []}

let item2 = {id = 11; price = 1222.0; name = "camo leggings"; 
             description = "a nice pair of leggings"; 
             category = "clothing";
             seller = talia_user_id;
             offers = []}

(** removing a user *)
let user_state_three = remove_user user_state_two user_one

(** adding item to user two *)
let user_state_four = add_item_to_user user_state_three "Talia Attar" 10
let new_user_two = get_user user_state_four "Talia Attar" 
let user_two_listing = new_user_two.listed

(** adding second item to user two*)
let user_state_six = add_item_to_user user_state_four "Talia Attar" 11

(** removing an item from user two *)
let user_state_five = remove_item_from_user user_state_four "Talia Attar" 10
let new_user_two = get_user user_state_five "Talia Attar" 
let user_two_empty_listing = new_user_two.listed

(** tests using sample json file *)
let user_sample_state : Userstate.t = 
  users_from_json (Yojson.Basic.from_file "user_sample.json")

let user_sample_ids : User.id list = ["talia"; "tedi"; "eric"; "rachael"]

let user_three = {
  id = "eric";
  password = "alabama";
  listed = [5; 6];
}

let user_four = {
  id = "eric";
  password = "greenwich";
  listed = [5; 6];
}

let user_five = {
  id = "ishan";
  password = "felon";
  listed = [];
}

let userstate_tests = [
  get_users_test "test user one was added to state" 
    user_state_one ["Tedi Mitiku"];

  get_users_test "test user two was added to state" 
    user_state_two ["Talia Attar"; "Tedi Mitiku"];

  get_users_test "test users are retrieved into state from json" 
    user_sample_state user_sample_ids; 

  "test user one username exists" >:: 
  (fun _ -> assert (exists_username user_state_two "Tedi Mitiku"));

  get_users_test "user one was removed from users state" 
    user_state_three ["Talia Attar"];

  "test user two has new item added to listing" >:: 
  (fun _ -> assert_equal [10] user_two_listing);

  "test user two has no items listed after removing the only item" >:: 
  (fun _ -> assert_equal [] user_two_empty_listing);

  "test user three exists in current user state" >:: 
  (fun _ -> assert_equal (true) (exists_user user_sample_state user_three));

  "user four does not exists in current user state because incorrect password of 
    user eric" >:: 
  (fun _ -> assert_equal (false) (exists_user user_sample_state user_four));

  get_items_test "Testing to see Talia's listed items" user_state_six 
    "Talia Attar" [11;10];

  "test that UserIdTaken is raised when duplicate id is attempted to be added" 
  >::(fun _ -> assert_raises (UserIdTaken) 
         (fun _-> let _i : Userstate.t = (add_user user_sample_state user_four)
           in ()));

  "test that InvalidId is raised when attempting to remove a user that doesnt 
  exist" >:: (fun _ -> assert_raises (Userstate.InvalidId) 
                 (fun _-> let _i : Userstate.t = 
                            (remove_user user_sample_state user_five) in ()));

  "test that InvalidId is raised when attempting to get a user that doesnt 
  exist" >:: (fun _ -> assert_raises (Userstate.InvalidId) 
                 (fun _-> let _i : User.t = 
                            (get_user user_sample_state "ishan") in ()));

  get_user_test "test eric is retreived from user sample state" 
    user_sample_state "eric" user_three;

]

(*--------------------------itemstate tests--------------------------------*)

(** [get_items_test name items exp_output] is a helepr function to test
    retrieval of item_ids from [items].] *)
let get_items_test 
    (name : string)
    (items : Itemstate.t)
    (exp_output : Item.id list): test= 
  name >:: (fun _ ->
      assert_equal ~cmp:cmp_set_like_lists 
        exp_output (get_items items))

(** [get_categories_test name items exp_output] is a helepr function to test
    retrieval of a list of categories from[items].] *)
let get_categories_test 
    (name : string)
    (items : Itemstate.t)
    (exp_output : Item.category list): test= 
  name >:: (fun _ ->
      assert_equal ~cmp:cmp_set_like_lists ~printer:(pp_list pp_string) 
        exp_output (get_item_categories items))

(** [get_item_prices_test name items exp_output] is a helepr function to test
    retrieval of a list of prices associated with the items in [items]. *)
let get_item_prices_test 
    (name : string)
    (items : Itemstate.t)
    (exp_output : Item.price list): test= 
  name >:: (fun _ ->
      assert_equal ~cmp:cmp_set_like_lists 
        exp_output (get_item_prices items))

(** [get_items_by_cat_test name items cat exp_output] is a helper function to 
    test retrieval of a all items with a of [cat] in [items]. *)
let get_items_by_cat_test 
    (name : string)
    (items : Itemstate.t)
    (cat : Item.category)
    (exp_output : Item.t list): test= 
  name >:: (fun _ ->
      assert_equal ~cmp:cmp_set_like_lists 
        exp_output (get_items_by_cat items cat))

(** [find_items_test items item_id] is a helper function to 
    test retrieval of an item from [items] using [item_id] *)
let find_items_test 
    (name : string)
    (items : Itemstate.t)
    (item_id: Item.id)
    (exp_output : Item.t ): test= 
  name >:: (fun _ ->
      assert_equal exp_output (find_item items item_id))


let init_item_state = empty_item_state ()

let user_three = {
  id = "Eric Osband";
  password = "alabama>greenwich";
  listed = [1];
}

let item_one = {id = 1; price = 20.00; name = "Erics shirt"; 
                description = "An ugly shirt"; 
                category = "clothes";
                seller = "Eric Osband";
                offers = []}

let user_four = {
  id = "Rachael Adelson";
  password = "bakery";
  listed = [2];
}

let item_two = {id = 2; price = 50000000.00; name = "STEM tutoring"; 
                description = "Rachael's tutoring scheme"; 
                category = "service";
                seller = "Rachael Adelson";
                offers = []}

(* add items *)
let item_state_one = add_item init_item_state item_one
let item_state_two = add_item item_state_one item_two

(* remove item *)
let item_state_three = remove_item item_state_two 1

(* add offer *)
let offer_one = {buyer = "Tedi"; price = 10.41; item_id = 2; id = "2-1"}
let item_state_four = add_offer_to_item item_state_three item_two offer_one

(* remove offer *)
let item_state_five = remove_offer_from_item item_state_four item_two offer_one

let item_sample_state : Itemstate.t = 
  items_from_json (Yojson.Basic.from_file "item_sample.json")

let item_sample_ids : Item.id list = [1; 2; 3; 4; 5; 6; 7; 8]

let item_sample_cats : Item.category list = ["clothes"; "textbooks"; "misc"]

let tb_one = {
  id = 3;
  price = 60.0;
  name = "math textbook";
  category = "textbooks";
  description = "textbook for linear algebra class (MATH 2940)";
  seller = "rachael";
  offers = []
}

let tb_two_offer = {
  buyer = "rachael";
  price = 10.0;
  item_id = 7;
  id = "7-1"
}

let tb_two = {
  id = 7;
  price = 15.0;
  name = "cs textbook";
  category = "textbooks";
  description = "The Pragmatic Programmer, used in CS 3110";
  seller = "tedi";
  offers = [tb_two_offer]
}

let itemstate_tests = [
  get_items_test "test retrieval of items into state from item sample json" 
    item_sample_state item_sample_ids;

  get_items_test "test items were added to init state" item_state_two [1; 2];

  get_categories_test "test categories were retrieved from item state" 
    item_state_two ["service"; "clothes"];

  get_categories_test "test categories were retrieved from item sample state" 
    item_sample_state item_sample_cats;

  get_item_prices_test "test prices were retrieved from item state" 
    item_state_two [20.00; 50000000.00];

  get_items_by_cat_test "test that item two was retrieved" 
    item_state_two "service" [item_two];

  get_items_by_cat_test "test that items of textbook category were retrieved" 
    item_sample_state "textbooks" [tb_one; tb_two];

  get_items_test "test item one was removed from item state" 
    item_state_three [2];

  find_items_test "finding the item corresponding to an id of 1" item_state_one 
    1 (item_one);

  find_items_test "finding the item corresponding to an id of 1" item_state_two 
    1 (item_one);

  find_items_test "finding the item corresponding to an id of 1" item_state_two 
    2 (item_two); 

  "test that InvalidId is raised when attempting to find an item of an item_id 
  that does not exist" >:: (fun _ -> assert_raises (Itemstate.InvalidId) 
                               (fun _-> let _i : Item.t = 
                                          (find_item item_state_one 81) in ()));


  "test offer one was added to item one" >:: 
  (fun _ -> assert_equal [offer_one] (find_item item_state_four 2).offers);

  "test offer one was removed from item one" >:: 
  (fun _ -> assert_equal [] (find_item item_state_five 2).offers);      

  "test cs textbook was found" >:: 
  (fun _ -> assert_equal tb_two (find_item item_sample_state 7));

  "test that InvalidId is raised when attempting to remove item that doesnt 
  exist" >:: (fun _ -> assert_raises (Itemstate.InvalidId) 
                 (fun _-> let _i : Itemstate.t = 
                            (remove_item item_sample_state 81) in ()));

  "test that InvalidId is raised when attempting to find item that doesnt exist"
  >:: (fun _ -> assert_raises (Itemstate.InvalidId) 
          (fun _-> let _i : Item.t = (find_item item_sample_state 81) in ()));
]

(** -------------------------transaction state tests--------------------------*)

let empty_trans_state = empty_trans_state ()

let trans_one = {
  id = 5;
  price = 25.00;
  name = "hat";
  seller = "tedi";
  buyer = "eric"
}

let trans_two = {
  id = 6; 
  price = 26.00;
  name = "tutoring";
  seller= "rachael";
  buyer = "eric"
}

let trans_three = {
  id = 7; 
  price = 27.00;
  name = "water";
  seller= "tedi";
  buyer = "talia"
}

let trans_state_two = add_transaction empty_trans_state trans_one
let trans_state_four = add_transaction trans_state_two trans_two
let trans_state_five = add_transaction trans_state_four trans_three

let transaction_tests = [
  "test transaction one was added to the transaction state by querying seller" 
  >::  (fun _ -> assert_equal [trans_one] (get_trans_by_seller trans_state_two 
                                             "tedi"));

  "test transaction one was returned when querying eric as the buyer" >:: 
  (fun _ -> assert_equal [trans_one] 
      (get_trans_by_buyer trans_state_two "eric"));

  "test correct transactions were returned when querying eric as the buyer" >:: 
  (fun _ -> assert_equal ~cmp:cmp_set_like_lists 
      ([trans_one; trans_two]) (get_trans_by_buyer trans_state_five "eric"));

  "test correct transactions were returned when querying tedi as the seller" >:: 
  (fun _ -> assert_equal ~cmp:cmp_set_like_lists 
      ([trans_one; trans_three]) (get_trans_by_seller trans_state_five "tedi"));

  "test no transactions were returned when querying a seller not in transaction 
  state" >:: (fun _ -> assert_equal ~cmp:cmp_set_like_lists 
                 ([]) (get_trans_by_seller trans_state_five "bachi"));

  "test no transactions were returned when querying a buyer not in transaction 
  state" >:: (fun _ -> assert_equal ~cmp:cmp_set_like_lists 
                 ([]) (get_trans_by_buyer trans_state_five "bachi"));

  "test trans_one was found" >:: 
  (fun _ -> assert_equal (trans_one) (find_trans trans_state_five 5));

  "test that InvalidId is raised when attempting to find transaction that 
  doesn't exist" >:: (fun _ -> assert_raises (Transactionstate.InvalidId) 
                         (fun _-> let _i : Transaction.t = 
                                    (find_trans trans_state_five 25) in ()));
]

(** -------------------------marketplace state tests--------------------------*)
let offer_a = {buyer = "Rachael Adelson"; price = 75.0; item_id = 5; id = "5-1"}
let offer_b = {buyer = "Ishan Bhatt"; price = 60.0; item_id = 5;  id = "5-2"}
let offer_c = {buyer = "Eric Osband"; price = 50.0; item_id = 5;  id = "5-3"}
let offer_d = {buyer = "Ishan Bhatt"; price = 10.0; item_id =1; id = "1-1"}

let item_a = {id = 1; price = 20.00; name = "Erics shirt"; 
              description = "An ugly shirt"; 
              category = "clothes";
              seller = "Eric Osband";
              offers = []}

let item_b = {id = 2; price = 50000000.00; name = "STEM tutoring"; 
              description = "Rachael's tutoring scheme"; 
              category = "service";
              seller = "Rachael Adelson";
              offers = []}

let item_c = {id = 3; price = 65.0; name = "Weighted Blanket"; 
              description = "A comfortable, fuzzy, blanket"; 
              category = "dorm essentials";
              seller = "Tedi Mitiku";
              offers = []}

let item_d = {id = 4; price = 200.0; name = "CHEM 2090 Textbooks"; 
              description = "A textbook for the worst enigneering class"; 
              category = "textbooks";
              seller = "Ishan Bhatt";
              offers = []}

let item_e = {id = 5; price = 100.0; name = "White Nike Hypervenoms"; 
              description = "Brand new white hypervenoms Womens size 6.5"; 
              category = "shoes";
              seller = "Nike";
              offers = [offer_a; offer_b; offer_c]}

let item_f = {id = 6; price = 130.0; name = "Air Force 1 Sage Low"; 
              description = "Brand AF1s in any color you like"; 
              category = "shoes";
              seller = "Nike";
              offers = []}

let item_g = {id = 7; price = 95.0; name = "Paddle Racket"; 
              description = "a used racket"; 
              category = "sports";
              seller = "Eric Osband";
              offers = []}

let item_aa = {id = 1; price = 20.00; name = "Erics shirt"; 
               description = "An ugly shirt"; 
               category = "clothes";
               seller = "Eric Osband";
               offers = [offer_d]}

let user_a = {
  id = "Tedi Mitiku";
  password = "tiff";
  listed = [3];
}

let user_b = {
  id = "Talia Attar";
  password = "tough";
  listed = [];
}
let user_c = {
  id = "Eric Osband";
  password = "alabama";
  listed = [1];
}

let user_d = {
  id = "Rachael Adelson";
  password = "bakery";
  listed = [2];
}

let user_e= {
  id = "Ishan";
  password = "felon";
  listed = [4];
}

let user_f= {
  id = "Nike";
  password = "justdoit";
  listed = [5;6];
}
let user_g= {
  id = "Gries";
  password = "noshoes";
  listed = [];
}

let user_aa = {
  id = "Tedi Mitiku";
  password = "tiff";
  listed = [];
}

let user_cc = {
  id = "Eric Osband";
  password = "alabama";
  listed = [];
}

let user_ccc = {
  id = "Eric Osband";
  password = "alabama";
  listed = [7;1];
}

let trans_a = {
  id = 7;
  price = 25.00;
  name = "hat";
  seller = "Tedi Mitiku";
  buyer = "Eric Osband"
}

let trans_b = {
  id = 8; 
  price = 26.00;
  name = "tutoring";
  seller= "Rachael Adelson";
  buyer = "Eric Osband"
}

let trans_c = {
  id = 9; 
  price = 27.00;
  name = "water";
  seller= "Tedi Mitiku";
  buyer = "Talia Attar"
}

let trans_d = {
  id = 1;
  price = 10.0;
  name = "Erics shirt";
  seller= "Eric Osband";
  buyer = "Ishan Bhatt"
}

let trans_e = {
  id = 3;
  price = 65.0;
  name = "Weighted Blanket";
  seller= "Tedi Mitiku";
  buyer = "Rachael Adelson"
}
let item_state  = {items = [item_a; item_b; item_c; item_d; item_e; 
                            item_f]; counter = 6}
let item_stateb  = {items = [item_aa; item_b; item_c; item_d; item_e; 
                             item_f]; counter = 6}
let item_statec =  {items = [item_b; item_c; item_d; item_e; 
                             item_f]; counter = 6}
let item_stated = {items = [item_a; item_b; item_d; item_e; 
                            item_f]; counter = 6}
let item_statee = {items = [item_g; item_a; item_b; item_c; item_d; item_e; 
                            item_f]; counter = 7}   
let user_state  = [user_a; user_b; user_c; user_d; user_e; user_f]
let user_stateb  = [user_cc; user_a; user_b; user_d; user_e; user_f]
let user_statec  = [user_aa; user_b; user_c; user_d; user_e; user_f]
let user_stated = [user_ccc; user_a; user_b; user_d; user_e; user_f]
let trans_state = [trans_a; trans_b; trans_c]
let trans_stateb =  [trans_d; trans_a; trans_b; trans_c]
let trans_statec =  [trans_e; trans_a; trans_b; trans_c]
let market_place = {item_state = item_state; user_state = user_state; 
                    trans_state = trans_state}
let market_placeb = {item_state = item_stateb; user_state = user_state; 
                     trans_state = trans_state}
let market_placec =  {item_state = item_statec; user_state = user_stateb; 
                      trans_state = trans_stateb}
let market_placed = {item_state = item_state; user_state = user_g::user_state; 
                     trans_state = trans_state}
let market_placee = {item_state = item_stated; user_state = user_statec; 
                     trans_state = trans_statec}

let market_placef = {item_state = item_statee; user_state = user_stated; 
                     trans_state = trans_state}


let validate_username_test
    (name : string)
    (mp : Marketplace.t)
    (user : User.id)
    (exp_output : bool): test= 
  name >:: (fun _ ->
      assert_equal  
        exp_output (Marketplace.validate_username mp user))

let categories_test
    (name : string)
    (mp : Marketplace.t)
    (exp_output : Item.category list): test= 
  name >:: (fun _ ->
      assert_equal ~cmp:cmp_set_like_lists 
        exp_output (Marketplace.categories mp))

let sold_trans_test 
    (name : string)
    (mp : Marketplace.t)
    (seller : Transaction.seller)
    (exp_output : Transaction.t list): test= 
  name >:: (fun _ ->
      assert_equal ~cmp:cmp_set_like_lists 
        exp_output (Marketplace.sold_trans mp seller))

let bought_trans_test 
    (name : string)
    (mp : Marketplace.t)
    (buyer : Transaction.seller)
    (exp_output : Transaction.t list): test= 
  name >:: (fun _ ->
      assert_equal ~cmp:cmp_set_like_lists 
        exp_output (Marketplace.bought_trans mp buyer))

let find_item_test 
    (name : string)
    (mp : Marketplace.t)
    (id : Item.id)
    (exp_output : Item.t): test= 
  name >:: (fun _ ->
      assert_equal exp_output (Marketplace.find_item mp id))

let find_tran_test 
    (name : string)
    (mp : Marketplace.t)
    (id : Transaction.id)
    (exp_output : Transaction.t): test= 
  name >:: (fun _ ->
      assert_equal exp_output (Marketplace.find_trans mp id))

let get_items_of_cat_test 
    (name : string)
    (mp : Marketplace.t)
    (cats: Item.category list)
    (exp_output : Item.t list): test= 
  name >:: (fun _ ->
      assert_equal ~cmp:cmp_set_like_lists 
        exp_output (Marketplace.get_items_of_cat mp cats))

let get_items_by_user_test 
    (name : string)
    (mp : Marketplace.t)
    (user: User.id)
    (exp_output : Item.t list): test= 
  name >:: (fun _ ->
      assert_equal ~cmp:cmp_set_like_lists 
        exp_output (Marketplace.get_items_by_user mp user))

let sell_test 
    (name : string)
    (mp : Marketplace.t)
    (item: Item.t)
    (exp_output : Item.id * Marketplace.t): test= 
  name >:: (fun _ ->
      assert_equal
        exp_output (Marketplace.sell_item mp item))

let buy_test 
    (name : string)
    (mp : Marketplace.t)
    (item: Item.id)
    (buyer: Basic.user_id)
    (exp_output : Transaction.t * Marketplace.t): test= 
  name >:: (fun _ ->
      assert_equal
        exp_output (Marketplace.buy_item mp item buyer))

let make_offer_test 
    (name : string)
    (mp : Marketplace.t)
    (offer: Offer.t)
    (exp_output : Offer.id * Marketplace.t): test= 
  name >:: (fun _ ->
      assert_equal 
        exp_output (Marketplace.make_offer mp offer))

let find_offer_test 
    (name : string)
    (mp : Marketplace.t)
    (id: Offer.id)
    (exp_output : Offer.t): test= 
  name >:: (fun _ ->
      assert_equal 
        exp_output (Marketplace.find_offer mp id))

let accept_offer_test 
    (name : string)
    (mp : Marketplace.t)
    (offer: Offer.id)
    (seller: Basic.user_id)
    (exp_output :  Transaction.t * Marketplace.t): test= 
  name >:: (fun _ ->
      assert_equal 
        exp_output (Marketplace.accept_offer mp offer seller))

let decline_offer_test 
    (name : string)
    (mp : Marketplace.t)
    (offer: Offer.id)
    (exp_output :  Marketplace.t): test= 
  name >:: (fun _ ->
      assert_equal 
        exp_output (Marketplace.decline_offer mp offer))

let get_offers_by_user_test 
    (name : string)
    (mp : Marketplace.t)
    (username: Offer.buyer)
    (exp_output :  Offer.t list * Item.t list ): test= 
  name >:: (fun _ ->
      assert_equal 
        exp_output (Marketplace.get_offers_by_user mp username))

let create_user_test 
    (name : string)
    (mp : Marketplace.t)
    (user: User.t)
    (exp_output :  Marketplace.t): test= 
  name >:: (fun _ ->
      assert_equal 
        exp_output (Marketplace.create_user mp user))

let authenticate_user_test 
    (name : string)
    (mp : Marketplace.t)
    (user : User.t)
    (exp_output : bool): test= 
  name >:: (fun _ ->
      assert_equal  
        exp_output (Marketplace.authenticate_user mp user))


let marketplace_tests = [
  validate_username_test "testing to see if new user can be added with username"
    market_place "Remi White" true; 
  validate_username_test "testing to see if new user can be added with username"
    market_place "Rachael Adelson" false; 
  categories_test "testing to see if the correct categories of marketplace are 
        returned" market_place ["clothes"; "shoes"; "dorm essentials"; "service"; 
                                "textbooks"];
  sold_trans_test "testing to see transactions where Tedi was the seller"
    market_place "Tedi Mitiku" [trans_a; trans_c];
  sold_trans_test "returns and empty list when there are no transactions for 
      seller" market_place "Michael Clarkson" [];
  bought_trans_test "testing to see transactions where Eric was the buyer"
    market_place "Eric Osband" [trans_a; trans_b];
  bought_trans_test "returns and empty list when there are no transactions for 
      buyer" market_place "Michael Clarkson" [];
  find_item_test "testing to find item 1" market_place 1 item_a; 
  find_item_test "testing to find item 4" market_place 4 item_d;
  "test that InvalidId is raised when attempting to find an item that does not 
    exist" >:: (fun _ -> assert_raises (Itemstate.InvalidId) 
                   (fun _-> let _i : Item.t = 
                              (Marketplace.find_item market_place 45) in ()));
  find_tran_test "testing to find transaction of water" market_place 9 trans_c;
  "test that InvalidId is raised when attempting to find a transaction for an 
      item id that does not exist" 
  >::(fun _ -> assert_raises (Transactionstate.InvalidId) 
         (fun _-> let _i : Transaction.t = 
                    (Marketplace.find_trans market_place 45) in ()));
  get_items_of_cat_test "testing to find items of clothing and shoes categories"
    market_place ["clothes"; "shoes"] [item_a; item_e; item_f];
  get_items_of_cat_test "testing that no items are returned for an empty list"
    market_place [] [];
  get_items_by_user_test "testing to find items listed by Nike" market_place 
    "Nike" [item_e; item_f];
  get_items_by_user_test "testing to find items listed by Talia" market_place 
    "Talia Attar" [];
  buy_test "testing that marketplace is updated correctly when weighted blanket
     is bought" market_place 3 "Rachael Adelson" (trans_e, market_placee); 

  sell_test "testing that marketplace is updated correctly when paddle is sold" 
    market_place item_g (7, market_placef);

  make_offer_test "testing that an offer is correctly added to marketplace" 
    market_place offer_d ("1-1", market_placeb);
  find_offer_test "testing to find offer correspoinding to id 5-1" market_place 
    "5-1" offer_a;
  find_offer_test "testing to find offer correspoinding to id 5-2" market_place 
    "5-2" offer_b;
  "test that InvalidId is raised when attempting to find an offer for an 
      item id that does not exist" 
  >::(fun _ -> assert_raises (Itemstate.InvalidId) 
         (fun _-> let _i : Offer.t = 
                    (Marketplace.find_offer market_place "34-2") in ()));
  "test that InvalidOfferEntered is raised when attempting to find an offer
    that does not exist" 
  >::(fun _ -> assert_raises (Marketplace.InvalidOfferEntered) 
         (fun _-> let _i : Offer.t = 
                    (Marketplace.find_offer market_place "3-442") in ()));                  
  accept_offer_test "testing to see if marketplace was correctly updated when an 
      offer was accepted" market_placeb "1-1" "Eric Osband" (trans_d, market_placec);
  decline_offer_test "testing that an offer was correctly declined" 
    market_placeb "1-1" market_place;
  get_offers_by_user_test "testing that the valid offer and item infromation is 
    returned for a user" market_placeb "Ishan Bhatt" 
    ([offer_b; offer_d], [item_e; item_aa]);
  create_user_test "testing that user is properlty created" market_place user_g 
    market_placed;
  authenticate_user_test "testing that Rachael is an authenticated user" 
    market_place user_d true;
  authenticate_user_test "testing that David Gries is not an authenticated user" 
    market_place user_g false ;
]
(* ------ test suite -------- *)
let suite =
  "test suite for final"  >::: List.flatten [
    command_tests;
    user_tests;
    item_tests;
    offer_tests;
    userstate_tests;
    itemstate_tests;
    transaction_tests;
    marketplace_tests;
  ]

let _ = run_test_tt_main suite