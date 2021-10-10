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
