# Competiwatch

[![Build Status](https://travis-ci.org/cheshire137/competiwatch.svg?branch=master)](https://travis-ci.org/cheshire137/competiwatch)

A web app to let you track your competitive match history in Overwatch. Shows charts
for each season. Lets you track your SR, what map you played on, which heroes you
played, whether there were throwers or leavers in your game, the time of day you
played, whether you played on a weekday or weekend, and notes for each game. Allows
you to import past seasons from a spreadsheet as well as export your data.

[Donations are welcome](https://www.patreon.com/cheshire137) to help pay for server costs.

## Screenshots

![Screenshot of match history](https://raw.githubusercontent.com/cheshire137/competiwatch/master/screenshot-top.png)

----

![Screenshot of match form](https://raw.githubusercontent.com/cheshire137/competiwatch/master/screenshot-log.png)

----

![Screenshot of trends](https://raw.githubusercontent.com/cheshire137/competiwatch/master/screenshot-trends.png)
![Screenshot of charts](https://raw.githubusercontent.com/cheshire137/competiwatch/master/screenshot-charts.png)
![Screenshot of map chart](https://raw.githubusercontent.com/cheshire137/competiwatch/master/screenshot-map-chart.png)

## How to Develop

You will need Ruby, [Bundler](http://bundler.io/), PostgreSQL, and npm installed.

```bash
bundle install
npm install
bin/rake db:setup
```

[Create a Battle.net API app](https://dev.battle.net), `cp dotenv.sample .env`, and
copy your Battle.net app key and secret into the .env file as `BNET_APP_ID`
and `BNET_APP_SECRET`.

You will also need to use a service like [ngrok](https://ngrok.com/) to have a public URL
that will hit your local server. Start ngrok via `ngrok http 3000`;
look at the https URL it spits out. In your Battle.net app, set
`https://your-ngrok-id-here.ngrok.io/accounts/auth/bnet/callback` as
the "Register Callback URL" value. Set `https://your-ngrok-id-here.ngrok.io`
as "Web Site". Update .env so that `BNET_APP_HOST` is set to your `your-ngrok-id-here.ngrok.io`.

Start the Rails server via `bundle exec rails s`. Now you should be able to go to
`https://your-ngrok-id-here.ngrok.io/` and sign in via Battle.net.

## Architecture

Models in Competiwatch:

![Entity relationship diagram](https://raw.githubusercontent.com/cheshire137/competiwatch/master/erd-2018-03-20.jpg)

## How to Deploy to Heroku

Create an [app on Heroku](https://dashboard.heroku.com/new-app).

Create a [Battle.net app](https://dev.battle.net) and set its "Register Callback URL" to
`https://your-heroku-app.herokuapp.com/accounts/auth/bnet/callback`. Set
`https://your-heroku-app.herokuapp.com` as the "Web Site".

```bash
heroku git:remote -a your-heroku-app
heroku config:set BNET_APP_ID=your_app_id_here
heroku config:set BNET_APP_SECRET=your_app_secret_here
heroku config:set BNET_APP_HOST=your-heroku-app.herokuapp.com
heroku config:set DONATE_URL="your Patreon/PayPal/etc URL for taking donations"
git push heroku master
heroku run rake db:migrate
heroku ps:scale web=1
heroku open
```

When deploying a migration to Heroku:

```bash
heroku maintenance:on
git push heroku master
heroku run rake db:migrate
heroku maintenance:off
```

### SSL

The app is set up for an SSL certificate from Let's Encrypt. When using certbot to generate
a certificate, put the value it gives you in this app's `.env` file in `LETS_ENCRYPT_VALUE`.
See [this article](https://medium.com/should-designers-code/how-to-set-up-ssl-with-lets-encrypt-on-heroku-for-free-266c185630db) for steps.

To add a certificate initially:

```bash
heroku certs:add /etc/letsencrypt/live/your-domain/fullchain.pem /etc/letsencrypt/live/your-domain/privkey.pem
```

To renew a certificate:

```bash
sudo certbot renew
```

To update the certificate once it's been renewed:

```bash
heroku certs:update /etc/letsencrypt/live/your-domain/fullchain.pem /etc/letsencrypt/live/your-domain/privkey.pem
```

See [Renewing certificates with Certbot](https://certbot.eff.org/docs/using.html#renewing-certificates).

### Database Backups

To back up the database from Heroku, you can use `bin/backup-database` which will
capture the current state of the Heroku database, download it, and move the dump
file to the directory specified in the `BACKUP_DIR` environment variable.

Example:

```bash
BACKUP_DIR=~/Dropbox bin/backup-database
```

## Admin Accounts

You can set some accounts as administrators that can see general data such as how many
matches have been logged and which Battle.net accounts have signed in. Using a Rails
console, set the `admin` flag to `true`. On Heroku, for example:

```bash
heroku run rails c
account = Account.find_by_battletag('TheBigBoss#1234')
account.admin = true
account.save
```

Once an account is marked as an admin, a new 'Admin' link will appear when they sign in using
that account. You must sign in as the admin account, you can't sign in as one of the linked
accounts tied to the same user.

## Thanks

See [the libraries I'm using](https://github.com/cheshire137/competiwatch/network/dependencies).

- [OWAPI](https://github.com/Fuyukai/OWAPI)
- [Chart.js library](http://www.chartjs.org/)
- [Primer CSS library](https://github.com/primer/primer)
- [Taggle.js](https://sean.is/poppin/tags)
