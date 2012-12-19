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

    `heroku run rake user:destroy[uuid]`
    `heroku run rake user:destroy[12345]`

2. Set account balaance

    `heroku run rake user:set_account_balance[uuid,new_account_balance]`
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
