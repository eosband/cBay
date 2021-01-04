# cBay-backend

An OCaml backend application that powers cBay. 

Below you can find the API specification. This API can be used either 
through Postman for testing or from 
[cBay-frontend](https://github.coecis.cornell.edu/eo255/cBay-frontend) 
terminal application.
To install cBay-backend locally, follow instructions in INSTALL.txt.

Backend deployed on Google VM Instance at http://35.245.220.250/api/


CS 3110 Final Project
Eric Osband (eo255), Rachael Adelson (rma249), Talia Attar (tda25), 
and Tewodros Mitiku (tmb42).




```
BASE_URL: //localhost:8000
```



```
POST .../api/account/create
```




*   Params
    *   (string) username is client username
    *   (string) password is client password
    *   Body: { “username”: &lt;username>, “password”: &lt;password> } 
*   Returns
    *   200 if the user successfully created.
        *   { “success”:true/false , “data”: “Account created successfully.” } 
    *   406 username already taken. 
        *   { “success”:true/false , “error”: “Username already taken.” } 


```
POST .../api/account/authenticate
```


*   Params
    *   (string) username is client username
    *   (string) password is client password
    *   Body: { “username”: &lt;username>, “password”: &lt;password> } 
*   Returns
    *   200 if the authentication is successful.
        *   { “success”: true , “true”:”Authenticated.”} 
    *   406 if authentication was unsuccessful, ex. Incorrect password, no account with username.
        *   { “success”: false , “error”: “Invalid password.”} 


```
GET .../api/account/validate/<username>
```


*   Params
    *   None
*   Returns
    *   200 - if the username is valid.
        *   { “success”:true , “data”: “Valid username.” } 
    *   406 - if authentication was unsuccessful, ex. Incorrect password, no account with username.
        *   { “success”:false , “error”: “Invalid username” } 


```
GET .../api/marketplace
```


*   Params
    *   None
*   Returns 
    *   200 - JSON of Marketplace was returned successfully.
        *   { “success”: true, “data”: [ {  “users”: &lt;users> }, {  “items”: &lt;items>, “counter”: &lt;counter> }, { “transactions”: &lt;transactions}] }
    *   406 - If error occurred in retrieving Marketplace.
        *   { “success”: false, “error”: “Error retrieving marketplace.” }


```
POST .../api/marketplace/reset
```


*   Params
    *   None
*   Returns 
    *   200 - JSON of Marketplace was reset successfully.
        *   { “success”: true, “data”: [ {  “users”: &lt;users> }, {  “items”: &lt;items>, “counter”: &lt;counter> }, { “transactions”: &lt;transactions}] }
    *   406 - If error occurred in resetting the Marketplace.
        *   { “success”: false, “error”: “Error retrieving marketplace.” }


```
POST .../api/marketplace/buy
```


*   Params
    *   (int) item_id
    *   (int) user_id
    *   Body: { “item_id”: &lt;item_id>, “user_id”:&lt;user_id> } 
*   Returns
    *   200 if item is bought successfully
        *   { “success”: true , “data”: { “transaction”: &lt;transaction>} } 
    *   406 - If the buyer tries to buy invalid item 
        *   { “success”: false , “error”: “Invalid item id.” } 


```
POST .../api/marketplace/sell
```


*   Params
    *   (string) item_id
    *   (float) price 
    *   (string) name
    *   (string) category
    *   (string) description
    *   (string) seller
    *   Body: &lt;item>
*   Returns
    *   200 - if listing is successfully made.
        *   { “success”: true , “data”: { “item_id”: &lt;item_id> } } 
    *   500 - if something went wrong attempting to sell an item.
        *   { “success”: true , “data”: { “item_id”: &lt;item_id> } }


```
GET .../api/marketplace/categories
```


*   Params
    *   None
*   Returns 
    *   200 - List of categories
        *   { “success”: true, “data”: [&lt;categories>, &lt;categories>,...]}


```
POST .../api/marketplace/categories
```


*   Params
    *   (string list) categories
    *   Body: { “categories”: [ &lt;category>, &lt;category>,.....]}
*   Returns 
    *   200 - If list of items in categories returned.
        *   { “success”: true, “data”: [ &lt;item>, &lt;item>,&lt;item>,&lt;item>,...] }


```
POST .../api/marketplace/offer
```


*   Params
    *   (json) offer
        *   (string) buyer
        *   (float) price
        *   (int) item id
    *   Body: &lt;offer>
*   Returns 
    *   200 - If the offer was initiated successfully.
        *   { “success”: true, “data”: {“offer_id” : &lt;offer_id>} }
    *   406 - If error occurred when trying to initiate an offer.
        *   { “success”: false, “error”: “Invalid item id.” }


```
POST .../api/marketplace/offer/accept
```


*   Params
    *   (string) offer_id
    *   (string) seller
    *   Body: { “offer_id”: &lt;offer_id>, “seller”: &lt;seller>}
*   Returns 
    *   200 - Offer was successfully accepted.
        *   { “success”: true, “data”: { “transaction”: &lt;transaction> }}
    *   406 - If a user tries to accept an offer of invalid Item.
        *   { “success”: false, “error”: “Invalid item id.” }
    *   406 - If a user tries to accept an offer that does not exist.
        *   { “success”: false, “error”: “Invalid offer entered.” }


```
POST .../api/marketplace/offer/decline
```


*   Params 
    *   (string) offer_id
    *   (string) seller
    *   Body: { “offer_id”: &lt;offer_id>, “seller”: &lt;seller>}
*   Returns 
    *   200 - Offer was successfully declined.
        *   { “success”: true, “data”: “Offer declined.”}
    *   406 -  If a user tries to decline an offer of invalid Item.
        *   { “success”: false, “error”: “Invalid item id.” }
    *   406 - If a user tries to accept an offer that does not exist.
        *   { “success”: false, “error”: “Invalid offer entered.” }


```
GET .../api/marketplace/offers/<username>
```


*   Params 
    *   None
*   Returns 
    *   200 - If items were retrieved successfully.
        *   { “success”: true, “data”:
        *   {“offers”:  [&lt;offer>, &lt;offer>,&lt;offer>,..], “items”:  [&lt;item>, &lt;item>,&lt;item>,..]}}
    *   406 -  If a user tries to decline an offer of invalid Item.
        *   { “success”: false, “error”: “Invalid username.” }


```
GET .../api/marketplace/items/<username>
```


*   Params 
    *   None
*   Returns 
    *   200 - If items were retrieved successfully.
        *   { “success”: true, “data”: [&lt;item>, &lt;item>,&lt;item>,..]}
    *   406 -  If a user tries to decline an offer of invalid Item.
        *   { “success”: false, “error”: “Invalid username.” }


```
GET .../api/marketplace/finditem/<item id>
```


*   Params 
    *   None
*   Returns 
    *   200 - If items were retrieved successfully.
        *   { “success”: true, “data”: &lt;item>}
    *   406 -  If there is no item with that id.
        *   { “success”: false, “error”: “Invalid item id.” }


```
GET .../api/marketplace/buyhist/<username>
```


*   Params 
    *   None
*   Returns 
    *   200 - If items were retrieved successfully.
        *   { “success”: true, “data”: [&lt;transaction>, &lt;transaction>, &lt;transaction>...]}
    *   406 -  If &lt;username> is not a valid username
        *   { “success”: false, “error”: “Invalid username.” }


```
GET .../api/marketplace/sellhist/<username>
```


*   Params 
    *   None
*   Returns 
    *   200 - If items were retrieved successfully.
        *   { “success”: true, “data”: [&lt;transaction>, &lt;transaction>, &lt;transaction>...]}
    *   406 -  If there is no item with that id.
        *   { “success”: false, “error”: “Invalid username.” }


```
GET .../api/marketplace/allhist/<username>
```


*   Params 
    *   None
*   Returns 
    *   200 - If items were retrieved successfully.
        *   { “success”: true, “data”: [&lt;transaction>, &lt;transaction>, &lt;transaction>...]}
    *   406 -  If there is no item with that id.
        *   { “success”: false, “error”: “Invalid username.” }
