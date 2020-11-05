running cypress locally involves two terminal windows:

1) run `bundle exec rails s -p 4040`

2) run `yarn cypress open`

OR
run `npm run test:e2e`


The files cypress reside in the cypress folder.

The cypress/integration folder is where all of the integration tests reside.

support/commands.js has code that can be shared multiple times.
