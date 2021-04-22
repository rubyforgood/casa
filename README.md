# CASA Project and Organization Overview

![rspec](https://github.com/rubyforgood/casa/workflows/rspec/badge.svg)
![cypress](https://github.com/rubyforgood/casa/workflows/cypress/badge.svg)
![erb lint](https://github.com/rubyforgood/casa/actions/workflows/erb_lint.yml/badge.svg)
![standardrb lint](https://github.com/rubyforgood/casa/actions/workflows/ruby_lint.yml/badge.svg)
![brakeman](https://github.com/rubyforgood/casa/workflows/brakeman/badge.svg)

[![Maintainability](https://api.codeclimate.com/v1/badges/24f3bb10db6afac417e2/maintainability)](https://codeclimate.com/github/rubyforgood/casa/trends/technical_debt)
[![Test Coverage](https://api.codeclimate.com/v1/badges/24f3bb10db6afac417e2/test_coverage)](https://codeclimate.com/github/rubyforgood/casa/trends/test_coverage_total)
[![View performance data on Skylight](https://badges.skylight.io/status/tFh7xrs3Qnaf.svg?token=1C-Q7p8jEFlG7t69Yl5DaJwa-ipWI8gLw9wLJf53xmQ)](https://www.skylight.io/app/applications/tFh7xrs3Qnaf)
[![Snyk Vulnerabilities](https://snyk.io/test/github/rubyforgood/casa/badge.svg)](https://snyk.io/test/github/rubyforgood/casa)
[![Average time to resolve an issue](http://isitmaintained.com/badge/resolution/rubyforgood/casa.svg)](http://isitmaintained.com/project/rubyforgood/casa "Average time to resolve an issue")

CASA (Court Appointed Special Advocate) is a role fulfilled by a trained volunteer sworn into a county-level juvenile dependency court system to advocate on behalf of a youth in the corresponding county's foster care system. CASA is also the namesake role of the national organization, CASA, which exists to cultivate and supervise volunteers carrying out this work – with county level chapters (operating relatively independently of each other) across the country.

## Welcome contributors!

We are very happy to have you! CASA and Ruby for Good are committed to welcoming new contrinbutors of all skill levels. We have plenty of tiny, small, and medium issues. 

We highly recommend that you join us in slack https://rubyforgood.herokuapp.com/ #casa channel to ask questions quickly and hear about office hours (currently Wednesday 6-8pm Pacific), stakeholder news, and upcoming new issues.

Issues on the issue board https://github.com/rubyforgood/casa/projects/1 in the TODO column are fair game. To claim an issue, comment on it "I am working on this issue".

Pull requests which are not for an issue but which improve the codebase by adding a test or improving the code are also welcome! Feel free to make github issues when you notice issues. A maintainer will be keeping an eye on issues and PRs every day or three. 

See also our [contributing guide](./doc/CONTRIBUTING.md) 💖

### About this project

CASA is a national organization with many regional chapters. We currenly work with Prince George's County CASA in Maryland and Montgomery CASA Maryland

This system provides value by:

- providing volunteers with a portal for logging activity
- allow supervisors to oversee volunteer activity
- generate reports on volunteer activity for admins to use in grant proposals

Read about the [product sense](doc/productsense.md) that guides our approach to this work.

**How CASA works:**

- Foster Youth (or case worker associated with Foster Youth) requests a CASA Volunteer.
- CASA chapter pairs Youth with Volunteer.
- Volunteer spends significant time getting to know and supporting the youth, including at court appearances.
- Case Supervisor oversees CASA Volunteer paired with Foster Youth and monitors, tracks, and advises on all related activities.
- At PG CASA, the minimum volunteer commitment is one year (this varies by CASA chapter, in San Francisco the minimum commitment is ~ two years). Many CASA volunteers remain in a Youth's life well beyond their youth. The lifecycle of a volunteer is very long, so there's a lot of activity for chapters to track!

**Why?**

Many adults circulate in and out of a Foster Youth's life, but very few of them (if any) remain. CASA volunteers are by design, unpaid, unbiased, and consistent adult figures for Foster Youth who are not bound to support them by fiscal or legal requirements.

**Project Terminology**

- Foster Youth = _CasaCase_
- CASA Volunteer = _Volunteer_
- Case Supervisor = _Case Supervisor_
- CASA Administrator = _Superadmin_

**Project Considerations**

- PG CASA is operating under a very tight budget. Right now, they manually input volunteer data into [a volunteer management software built specifically for CASA](http://www.simplyoptima.com/), but upgrading their account for multiple user licenses to allow volunteers to self-log activity data is beyond their budget. Hence why we are building as lightweight a solution as possible that can sustain itself with Ruby for Good's support.
- While the scope of this platform's use is currently only for PG County CASA, we are building with a mind toward multitenancy so this platform could prospectively be used by CASA chapters across the country. We consider PG CASA an early beta tester of this platform.

**More information:**

Learn more about PG CASA [here](https://pgcasa.org/).

You can read the complete [role description of a CASA volunteer](https://pgcasa.org/volunteer-description/) in Prince George's County as well.

## Developing! ✨🛠✨

See [DOCKER.md](doc/DOCKER.md) for instructions on setting up your environment
using Docker. For non-Docker installations, follow the instructions below.

### Installing Tools

You need Ruby, bundler, node.js, yarn, postgres, and chromedriver.

**Ruby**

1. Install a ruby version manager: [rvm](https://rvm.io/) or [rbenv](https://github.com/rbenv/rbenv)
1. when you cd into the project directory, let your version manager install the ruby version in `.ruby-version`. Right now that's Ruby 2.7.2
1. `gem install bundler`

**node.js**

1. (Recommended) Install [nvm](https://github.com/nvm-sh/nvm#installing-and-updating), which is a **n**ode **v**ersion **m**anager.
1. Install a current LTS version of Node. 12.16.2 works.
1. Install [yarn](https://classic.yarnpkg.com/en/docs/install). On Ubuntu, [make sure you install it from the official Yarn repo instead of cmdtest](https://classic.yarnpkg.com/en/docs/install/#debian-stable).

**PostgreSQL ("postgres")**

1. Make sure that postgres is installed.

  - On a Mac, you can use [brew install postgres](https://wiki.postgresql.org/wiki/Homebrew) OR brew postgresql-upgrade-database if you have an older version of postgres, or use [Postgres.app](https://postgresapp.com/).
  - If you're on Ubuntu/WSL, use `sudo apt-get install libpq-dev` so the gem can install. [Use the Postgres repo for Ubuntu or WSL to get the server and client tools](https://www.postgresql.org/download/linux/ubuntu/).
  - If you're on Fedora/Cent Os use `sudo dnf install libpq-devel`. [If you prefer choose package of libpq-devel via rpm](https://pkgs.org/download/libpq-devel)
  - If you're on Windows, use the official [installer](https://www.postgresql.org/download/windows/) and accept all defaults.  Alternatively, a [Chocolatey](https://chocolatey.org/packages/postgresql) package is available with `choco install postgresql`.

**Chromedriver**

1. If you use the Chrome browser, that is enough. If not, install the current stable release of [chromedriver](https://chromedriver.chromium.org/) for your operating system so the browser-based Ruby feature/integration tests can run. Installing `chromium-browser` is enough, even in WSL.

### Running the app

(*on a Mac or Linux machine*)

1. `git clone https://github.com/rubyforgood/casa.git` clone the repo to your local machine. You should create a fork in GitHub if you don't have permission to commit directly to this repo, though. See [our contributing guide](doc/CONTRIBUTING.md) for more detailed instructions.
1. `cd casa/`
1. `bundle install` to install all the Ruby dependencies.
1. `yarn install` to install all the Javascript dependencies.
1. `bin/rails db:setup` requires running local postgres, with a role created for whatever user you're running rails as

**Running Tests**

1. `bin/rails spec` to run the Ruby test suite
1. `yarn test` to run the Javascript test suite

Test coverage is run by simplecov on all builds and aggregated by CodeClimate

**Running the development server**

1. `bin/rails db:seed:replant` to delete all existing data and load sample data into the database
1. `bin/rails server` run server

**Cleaning up before you commit**

1. `bundle exec standardrb --fix` auto-fix Ruby linting issues [more linter info](https://github.com/testdouble/standard)
1. `bundle exec erblint --lint-all --autocorrect` [ERB linter](https://github.com/Shopify/erb-lint)
1. `yarn lint:fix` to run the [JS linter](https://standardjs.com/index.html) and fix isses
1. `rake factory_bot:lint` if you have been editing factories and want to find factories and traits which produce invalid objects

If you have any troubles running tests, check out the files in `.github/workflow/` which is what makes the CI build run.

If additional work arises from your commit that is outside the scope of the issue it resolves, please open a new issue and either:
- assign it to yourself if you'd like to take it on
- or add it to the to-do column without an assignee so someone else can pick up this new issue.

**Local email**

We are using [Letter Opener](https://github.com/ryanb/letter_opener) in
development to receive mail. All emails sent in development should open in a
new tab in the browser.

**Post-deployment tasks**

We are using [After Party](https://github.com/theSteveMitchell/after_party) to
run post-deployment tasks. These tasks may include one-time necessary updates to the
database. Run the tasks manually by:

```
bundle exec rake after_party:run
```


Alternatively, every time you pull the main branch, run:

```
bin/update
```

which will run any database migrations, update gems and yarn packages, and run
the after party post-deployment tasks.

### Other Documentation

There is a `doc` directory at the top level that includes:

* an `architecture-decisions` directory containing important architectural decisions and entity relationship diagrams of various models
  (see the article [Architectural Decision Records](http://thinkrelevance.com/blog/2011/11/15/documenting-architecture-decisions) describing this approach).
* [Code of Conduct](doc/code-of-conduct.md)
* [CONTRIBUTING.md](doc/CONTRIBUTING.md)
* [CYPRESS.md](doc/CYPRESS.md)
* [DOCKER.md](doc/DOCKER.md)
* [LINUX_SETUP.md](doc/LINUX_SETUP.md)
* [productsense.md](doc/productsense.md)(for team leads & product interested contributors)
* [SECURITY.md](doc/SECURITY.md)

### Common issues

1. If your rake/rake commands hang forever instead of running, try: `rails app:update:bin`
1. There is currently no option for a user to sign up and create an account through the UI. This is intentional. If you want to log in, use a pre-seeded user account and its credentials.
1. If you are on windows and see the error "Requirements support for mingw is not implemented yet" then use https://rubyinstaller.org/ instead

### Ubuntu and WSL

1. If you are on Ubuntu in Windows Subsystem for Linux (WSL) and `rbenv install` indicates that the Ruby version is unavailable, you might be using Ubuntu's default install of `ruby-build`, which only comes with old installs of Ruby (ending before 2.6.) You should uninstall rvm and ruby-build's apt packages (`apt remove rvm ruby-build`) and install them with Git like this:

- `git clone https://github.com/rbenv/rbenv.git ~/.rbenv`
- `echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc`
- `echo 'eval "$(rbenv init -)"' >> ~/.bashrc`
- `exec $SHELL`
- `git clone https://github.com/rbenv/ruby-build.git "$(rbenv root)"/plugins/ruby-build`

You'll probably hit a problem where ruby-version reads `ruby-2.7.2` but the install available to you is called `2.7.2`. If you do, install [rbenv-alias](https://github.com/tpope/rbenv-aliases) and create an alias between the two.

## Non-development environments

See `db/seeds` for seed data. Test data includes the below

1. volunteer1@example.com / 123456 https://\<URL\>.herokuapp.com/
1. supervisor1@example.com / 123456 https://\<URL\>.herokuapp.com/
1. casa_admin1@example.com / 123456 https://\<URL\>.herokuapp.com/
1. casa_admin2-1@example.com / 123456 https://\<URL\>.herokuapp.com/ (for second tenant)
1. allcasaadmin@example.com / 123456 https://\<URL\>.herokuapp.com/all_casa_admins/sign_in

In the emails listed above, the number `1` corresponds to a `casa_org_id`. To log in to a different `casa_org`'s instance, change the `casa_org_id` number in the email, and add a hyphen and numerical value to the end. 

Example: To log into CASA Org 2's instance, use the following email: casa_admin2-1@example.com. In this example, the number `2` corresponds to the `casa_org`, and the number `1` corresponds to the user. 

### QA environment

When pull requests are merged, the code auto-deploys to QA (because of a heroku setting)

https://casa-qa.herokuapp.com/

If you would like to help run quality assurance, please check out the _Merged to QA_ section of our project board. For each ticket in this column, log into the QA environment to confirm whether or not this change has indeed been made and is working as intended. If yes, please add the label: _working-in-qa_ to the ticket. If it is not, please add the label: _not-working-in-qa_ to the ticket. If you discover bugs in this process, please file an issue for it, add the label: _bug_, and add it to the _To do_ column. ***This is a great task for PM contributors looking to familiarize themselves with the application and project board. 

### Staging

Deploy to Staging is manual. Training of new users is done in staging.

https://casa-r4g-staging.herokuapp.com/

### Production

We have real users in production!

If you represent a CASA organization which wants to use this, please contact us! polly@rubyforgood.org

See https://github.com/rubyforgood/casa/wiki for deploy & SRE notes

### Deployment
[Follow this Deployment Checklist](./DEPLOY_CHECKLIST.md)

### Error tracking

We are currently using https://app.bugsnag.com/ to track errors in staging. Errors post to slack at #casa-bots.

### Email

This app sends email for user signup and deactivation. We use https://www.sendinblue.com/ because we get 300 free emails a day, which is more than we expect to need.

Sendinblue has historically sometimes been very slow (6 hours) in delivering email, but sometimes it delivers within a minute or two. Be wary.

You log into sendinblue via the "log in with google" option. Sean has the credentials for this and hopefully we never need to change them.

We are not using Mailgun because they limited us to only 5 recipients without a paid plan. We looked at using Sendgrid but our account is currently locked for unknown reasons.

Preview all emails at http://localhost:3000/rails/mailers/volunteer_mailer as configured by `volunteer_mailer_preview.rb`

### Hosting

Namecheap, Heroku

## Communication and Collaboration

Most conversation happens in the #casa channel of the Ruby For Good slack. Get access here: https://rubyforgood.herokuapp.com/

You can also open an issue or comment on an issue on github and a maintainer will reply to you.

We have a weekly team office hours / hangout on Wednesday 6-8pm Pacific time where we do pair/mob programming and talk about issues. Please stop by!

We have a weekly stakeholder call with PG CASA staff on Wednesday at 8:30am Pacific time where we show off progress and discuss launch plans. Feel free to join!

Join info for all public meetings is posted in the rubyforgood slack in the #casa channel

### History

First CASA supervisor training: 12 August 2020 🎉
