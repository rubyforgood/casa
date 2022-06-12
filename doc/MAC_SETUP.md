## Assumptions

This guide assumes you have [homebrew](https://brew.sh/) installed.

You will need the following local tools installed:

1. Ruby
2. NodeJs (optional)
3. Postgres
4. Google Chrome

All dependencies are installed with homebrew.

### Ruby

Your Mac came with a version of ruby installed (when you installed homebrew you used it), however Apple is sometimes a little behind the current version and homebrew allows you to stey up to date.

[`brew install ruby`](https://formulae.brew.sh/formula/ruby#default)

If you installed ruby awhile ago and haven't updated it, the bundle installer may flag the need for an update, in which case use:

`brew upgrade ruby`

### NodeJS

The Casa package frontend leverages several javascript packages managed through `yarn`, so if you are working on those elements you will want to have node, npm, and yarn installed.

`brew install node`
`brew install yarn`

### Postgres

[`brew install postgresql`](https://wiki.postgresql.org/wiki/Homebrew)

If you have an older version of postgres, `brew postgresql-upgrade-database`

For a more GUI focused postgres experience, try [Postgres.app](https://postgresapp.com/) an alternative to the CLI focused default postgres

### Google Chrome

Many of the frontend tests are run using Google Chrome, so if you don't already have that installed you may wish to include it:

`brew install google-chrome`
--------------------------
Ruby Version
This app uses Ruby version 3.1.2, indicated in /.ruby-version and Gemfile, which will be auto-selected if you use a Ruby versioning manager like rvm, rbenv, or asdf.

Yarn Installation
If you don't have Yarn installed, you can install with Homebrew on macOS brew install yarn or visit https://yarnpkg.com/en/docs/install. Be sure to run yarn install after installing Yarn. NOTE: It's possible that Node version 12 may cause you problems, see issue #751. Node 10 or 11 seem to be fine.

Install dependencies using Yarn
Run yarn to install project dependencies.

Create your .env with database credentials
Be sure to create a .env file in the root of the app that includes the following lines (change to whatever is appropriate for your system):

PG_USERNAME=username
PG_PASSWORD=password
If you're getting the error PG::ConnectionBad: fe_sendauth: no password supplied, it's because you have probably not done this.

Database Configuration
This app uses PostgreSQL for all environments. You'll also need to create the dev and test databases, the app is expecting them to be named diaper_dev, diaper_test, partner_dev, and partner_test respectively. This should all be handled with rails db:setup. Create a database.yml file on config/ directory with your database configurations. You can also copy the existing file called database.yml.example as an example and just change the credentials.

Seed the database
From the root of the app, run bundle exec rails db:seed. This will create some initial data to use while testing the app and developing new features, including setting up the default user.

Start the app
Run bundle exec rails server or bin/start (recommended since it runs webpacker in the background!) an