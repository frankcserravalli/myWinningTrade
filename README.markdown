API
===
|    CONTROLLER            |      ACTION       |   WHAT DOES IT DO                                         |          URL                                  |                       PARAMS TO GIVE                                                                            |  JSON/Text Responses                                |
| ------------------------ | ----------------- | --------------------------------------------------------- | --------------------------------------------- | --------------------------------------------------------------------------------------------------------------- | --------------------------------------------------- |
|  api/v1/stocks           |  details          |  Returns the stock details                                |  api/v1/stocks/details                        |   symbol, ios_token                                                                                             |      Returns stock details See (1)                  |
|  api/v1/users            |  portfolio        |  Returns the stock details                                |  api/v1/stocks/details                        |   symbol, ios_token                                                                                             |      Returns stock details See (1)                  |



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
