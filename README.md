# CASA Project & Organization Overview
[![Dependabot Status](https://api.dependabot.com/badges/status?host=github&repo=rubyforgood/casa)](https://dependabot.com)
[![Maintainability](https://api.codeclimate.com/v1/badges/???/maintainability)](https://codeclimate.com/github/rubyforgood/casa/maintainability)
[![Test Coverage](https://api.codeclimate.com/v1/badges/???/test_coverage)](https://codeclimate.com/github/rubyforgood/casa/test_coverage)
[![Build Status](https://travis-ci.org/rubyforgood/casa.svg?branch=master)](https://travis-ci.org/rubyforgood/casa) 
[![View performance data on Skylight](https://badges.skylight.io/status/tFh7xrs3Qnaf.svg?token=1C-Q7p8jEFlG7t69Yl5DaJwa-ipWI8gLw9wLJf53xmQ)](https://www.skylight.io/app/applications/tFh7xrs3Qnaf)
[![Known Vulnerabilities](https://snyk.io/test/github/rubyforgood/casa/badge.svg)](https://snyk.io/test/github/rubyforgood/casa)

CASA (Court Appointed Special Advocate) is a role fulfilled by a trained volunteer sworn into a county-level juvenile dependency court system to advocate on behalf of a youth in the corresponding county's foster care system. CASA is also the namesake role of the national organization, CASA, which exists to cultivate and supervise volunteers carrying out this work – with county level chapters (operating relatively independently of each other) across the country. 

**PG CASA (Prince George's County CASA in Maryland) seeks a volunteer management system to:**
- provide volunteers with a portal for logging activity
- oversee volunteer activity
- generate reports on volunteer activity

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
- PG CASA is operating under a very tight budget. They currently _manually input volunteer data_ into [a volunteer management software built specifically for CASA](http://www.simplyoptima.com/), but upgrading their account for multiple user licenses to allow volunteers to self-log activity data is beyond their budget. Hence why we are building as lightweight a solution as possible that can sustain itself on Microsoft Azure nonprofit credits for hosting (totalling $3,500 annually).
- While the scope of this platform's use is currently only for PG County CASA, we are building with a mind toward multitenancy so this platform could prospectively be used by CASA chapters across the country. We consider PG CASA an early beta tester of this platform.


**More information:**

Learn more about PG CASA [here](https://pgcasa.org/).

You can read the complete [role description of a CASA volunteer](https://pgcasa.org/volunteer-description/) in Prince George's County as well.

### Want to contribute? Great!

[Here is our contributing guide!](./CONTRIBUTING.md)

### Staging Environment on Heroku

https://casa-r4g-staging.herokuapp.com/

### Error tracking

We are currently using https://app.bugsnag.com/ to track errors in staging. Errors post to slack at #casa-bots 

### Setup to develop:

If you have any troubles, also look at `.travis.yml` which is what makes the CI build run

1. install a ruby version manager: [rvm](https://rvm.io/) or [rbenv](https://github.com/rbenv/rbenv)
1. when you cd into the project diretory, let your version manager install the ruby version in `.ruby-version`
1. `gem install bundler`
1. Make sure that postgres is installed [brew install postgres](https://wiki.postgresql.org/wiki/Homebrew) OR brew postgresql-upgrade-database (if you have an older version of postgres)
1. Make sure [nvm](https://github.com/nvm-sh/nvm#installing-and-updating) is installed
1. Make sure [yarn](https://classic.yarnpkg.com/en/docs/instal) is installed
1. Make sure you have [google chrome](https://chromedriver.chromium.org/) installed so the selenium tests can run
1. `bundle install`
1. `yarn`
1. `bundle exec rails webpacker:compile`
1. `bundle exec rails db:setup # requires running local postgres`
1. `bundle exec rails spec`
1. `rails db:migrate`
1. `bundle exec rails server` # run server
1. `bundle exec standardrb --fix # auto-fix linting issues (optional)` [more linter info](https://github.com/testdouble/standard)

### Documentation

There is a `doc` directory at the top level that includes [Architectural Decision Records](http://thinkrelevance.com/blog/2011/11/15/documenting-architecture-decisions) and entity relationship diagram of various models.

#### Common issues

1. If your rake/rake commands hang forever instead of running, try: `rails app:update:bin`
1. There is currently no option for a user to sign up and create an account through the UI. This is intentional. If you want to log in, use a pre-seeded user account and its credentials.

### Communication

Most conversation happens in the #casa channel of the Ruby For Good slack. You can get access here: https://rubyforgood.herokuapp.com/

You can also open an issue or comment on an issue on github and a maintainer will reply to you. 
