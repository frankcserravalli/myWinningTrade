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


    

