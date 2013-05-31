API
===
|    CONTROLLER            |      ACTION       |   WHAT DOES IT DO                                         |          URL                                  |                       PARAMS TO GIVE                                                                            |  JSON/Text Responses                                |
| ------------------------ | ----------------- | --------------------------------------------------------- | --------------------------------------------- | --------------------------------------------------------------------------------------------------------------- | --------------------------------------------------- |
|  api/v1/stocks           |  details          |  Returns the stock details                                |  api/v1/stocks/details                        |   symbol, ios_token                                                                                             |      Returns stock details See (1)                  |
|  api/v1/users            |  portfolio        |  Returns the users portfolio                              |  api/v1/users/portfolio                       |   user_id, ios_token                                                                                            |      Returns user's portfolio See (2)               |
|  api/v1/users            |  create           |  Creates an user                                          |  api/v1/users/create                          |   name, email, password, password_confirmation                                                                  |      Returns user's id and ios token                |
|  api/v1/buys            |  create            |  Creates a buy order                                      |  api/v1/buys/create                           |   user_id, stock_id, volume, ios_token                                                                             |      Returns the buy order                          |
|  api/v1/sells            |  create            |  Creates a sell order                                    |  api/v1/sells/create                          |   user_id, stock_id, volume, ios_token                                                                            |      Returns the sell order                          |
|  api/v1/short_sell_covers|  create            |  Creates a short sell cover order                        |  api/v1/short_sell_covers                     |   user_id, stock_id, volume, ios_token                                                                            |      Returns the sell order                          |
| api/v1/short_sell_borrows|  create            |  Creates a short sell borrow order                       |  api/v1/short_sell_borrows                    |   user_id, stock_id, volume, ios_token, short_sell_borrow =>{ volume, when, execute_at(1i), execute_at(2i), execute_at(3i), execute_at(4i), execute_at(5i), measure, price_target }                                                                       |      status: "Order placed."                       |



(1) "{"table":{"name":"Apple Inc.","symbol":"AAPL","ask":"456.87","ask_realtime":"456.87","bid":"456.77",
"bid_realtime":"456.77","days_range":"453.70 - 465.75","year_range":"385.10 - 705.07","open":"465.24",
"previous_close":"460.71","volume":"11274406","dividend_yield":"1.73","earnings_share":"41.896",
"stock_exchange":"NasdaqNM","last_trade_time":"12:12pm","eps_estimate_current_year":"39.76",
"eps_estimate_next_year":"44.09","eps_estimate_next_quarter":"8.25","pe_ratio":"11.00",
"two_hundred_day_moving_average":"505.657","fifty_day_moving_average":"431.59",
"last_trade_date":"5/7/2013","currently_trading":true,"current_price":"456.87",
"current_bid":"456.77","buy_price":462.87,
"statements_url":"http://investing.money.msn.com/investments/sec-filings/?symbol=AAPL",
"point_change":"-3.84","percent_change":-0.83,"trend_direction":"down"},"modifiable":true}"


(2) {"current_value":1828.76,"cash":48433.16,"purchase_value":1566.84,"stocks":{"AAPL":{"name":"Apple Inc.","current_price":457.19,"shares_owned":4,"current_value":1828.76,"cost_basis":391.71,"capital_gain":65.48000000000002,"percent_gain":16.7}},"shorts":{},"pending_date_time_transactions":[],"processed_date_time_transactions":[],"pending_stop_loss_transactions":[],"processed_stop_loss_transactions":[],"percent_gain":16.7,"account_value":50261.92}



Deploying
===

1. Move into the base directory of the app.

    `cd ~/MyWinningTrade`

2. Make sure the code is up to date

    `git pull origin master`

3. Deploy to heroku

    `git push heroku master`

4. If the database has changed:

    `heroku run rake db:migrate`

5. Restart the server:

    `heroku restart`


Editing users
===

To get the unique id of the currently logged in user, paste the following in the browser URL bar and hit enter:

    javascript:uuid()

1. Destroy account

    `heroku run rake user:destroy[uid]`
    `heroku run rake user:destroy[12345]`

2. Set account balaance

    `heroku run rake user:set_account_balance[uid,new_account_balance]`
    `heroku run rake user:set_account_balance[12345,50000]`

Conclave Labs
===

Master Conclave Labs branch


Environent Variable
===

(Local) mywinningtrade.dev

FACEBOOK_APP_ID="298514626925253"
FACEBOOK_APP_SECRET="0de422445cad2b8ad09d8ecb8b748189"

(Stage) powerful-forest-8344.herokuapp.com     

FACEBOOK_APP_ID="349566425142206"
FACEBOOK_APP_SECRET="37279cb9a30d14949d011cadc12fd1ae"

(Production) mywinningtrade.com

FACEBOOK_APP_ID="331752936918078"
FACEBOOK_APP_SECRET="6dee4f074f905e98957e9328bf4d91a3"
