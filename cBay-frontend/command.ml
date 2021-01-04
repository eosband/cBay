
type command = 
  | Offer
  | Buy
  | View
  | Sell
  | Menu
  | Logout
  | Quit


exception Empty

exception Unknown 

let parse str = 
  match str with
  | "" -> raise Empty
  | "offer" -> Offer
  | "buy" -> Buy
  | "sell" -> Sell
  | "view" -> View
  | "help" -> Menu
  | "menu" -> Menu
  | "logout" -> Logout
  | "quit" -> Quit
  | _ -> raise Unknown

