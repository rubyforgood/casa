# Install Needed Dependencies

## Homebrew

If you haven't already, install the [homebrew](https://brew.sh/) package manager.

## Postgres

Use homebrew to install and run postgresql:

```bash
brew install postgresql
```

```bash
brew services start postgresql
```

If you have an older version of postgres, `brew postgresql-upgrade-database`

For a more GUI focused postgres experience, try [Postgres.app](https://postgresapp.com/) an alternative to the CLI focused default postgres

## Ruby

### Rbenv

It is often useful to install Ruby with a ruby version manager. The version of Ruby that comes with Mac is not sufficient
for this project. You can install [rbenv](https://github.com/rbenv/rbenv) with:

```bash
brew install rbenv ruby-build
```

Then, setup rbenv:

```bash
rbenv init
```

And finally, follow the setup instructions that are outputted to your terminal after running that.

### Actually installing Ruby

Next, install the version of Ruby that this project uses. This can be found by checking the file in this repo, `.ruby-version`.

To install the appropriate ruby version, run:

```bash
rbenv install 3.1.2
```

(Do not forget to switch 3.1.2 to the appropriate version)

Finally, run:

```bash
rbenv local 3.1.2
```
(Do not forget to swtich 3.1.2 to the appropriate version)

## Nodejs

The Casa package frontend leverages several javascript packages managed through `yarn`, so if you are working on those elements you will want to have node, npm, and yarn installed.

```bash
brew install node
```

```
brew install yarn
```

## Chrome
Many of the frontend tests are run using Google Chrome, so if you don't already have that installed you may wish to include it:

```bash
brew install google-chrome
```

## Project setup

Install gem dependencies with:

```bash
bundle install
```

Setup the database with:

```bash
bin/rails db:setup
```

Compile assets with:

```bash
yarn build
```

and then:

```bash
yarn build:css
```

And lastly, run the app with:

```bash
bin/rails server
```

See the README for login information.
