# CASA Project and Organization Overview

[![rspec](https://github.com/rubyforgood/casa/workflows/rspec/badge.svg)](https://github.com/rubyforgood/casa/actions/workflows/rspec.yml)
[![erb lint](https://github.com/rubyforgood/casa/actions/workflows/erb_lint.yml/badge.svg)](https://github.com/rubyforgood/casa/actions/workflows/erb_lint.yml)
[![standardrb lint](https://github.com/rubyforgood/casa/actions/workflows/ruby_lint.yml/badge.svg)](https://github.com/rubyforgood/casa/actions/workflows/ruby_lint.yml)
[![brakeman](https://github.com/rubyforgood/casa/workflows/brakeman/badge.svg)](https://github.com/rubyforgood/casa/actions/workflows/security.yml)
[![yarn lint](https://github.com/rubyforgood/casa/actions/workflows/yarn_lint_and_test.yml/badge.svg)](https://github.com/rubyforgood/casa/actions/workflows/yarn_lint_and_test.yml)

[![Maintainability](https://api.codeclimate.com/v1/badges/24f3bb10db6afac417e2/maintainability)](https://codeclimate.com/github/rubyforgood/casa/trends/technical_debt)
[![Test Coverage](https://api.codeclimate.com/v1/badges/24f3bb10db6afac417e2/test_coverage)](https://codeclimate.com/github/rubyforgood/casa/trends/test_coverage_total)
[![Snyk Vulnerabilities](https://snyk.io/test/github/rubyforgood/casa/badge.svg)](https://snyk.io/test/github/rubyforgood/casa)
[![Average time to resolve an issue](http://isitmaintained.com/badge/resolution/rubyforgood/casa.svg)](http://isitmaintained.com/project/rubyforgood/casa "Average time to resolve an issue")

A CASA (Court Appointed Special Advocate) is a role where a volunteer advocates on behalf of a youth in their county's foster care system. CASA is also the namesake role of the national organization, CASA, which exists to cultivate and supervise volunteers carrying out this work – with county level chapters (operating relatively independently of each other) across the country.

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**

  - [Welcome contributors!](#welcome-contributors)
    - [Communication and Collaboration](#communication-and-collaboration)
    - [About this project](#about-this-project)
- [Developing! ✨🛠✨](#developing-)
  - [How to Contribute](#how-to-contribute)
  - [Installation](#installation)
    - [Getting Started (Codespaces - EXPERIMENTAL) 🛠️](#getting-started-codespaces---experimental-)
    - [Local Setup Instructions](#local-setup-instructions)
    - [Platform Specific Installation Instructions](#platform-specific-installation-instructions)
    - [Common issues](#common-issues)
  - [Running the App / Verifying Installation](#running-the-app--verifying-installation)
- [Other Documentation](#other-documentation)
- [Acknowledgements](#acknowledgements)
- [Feedback](#feedback)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## Welcome contributors!

We are very happy to have you! CASA and Ruby for Good are committed to welcoming new contributors of all skill levels.

Find issues to work on [here](https://github.com/rubyforgood/casa/issues?q=is%3Aissue+is%3Aopen+no%3Aassignee) on the issue board. Issues on the [project's](https://github.com/rubyforgood/casa/projects/1) TODO column are another way to browse issues. Check to see that no one is assigned to the issue. Then comment on it to claim the issue. Commenting on an issue doesn't automatically get the issue assigned so double check the comments on an issue to see that no one is requesting assignment.  

Pull requests which are not for an issue but which improve the codebase are also welcome! Feel free to make GitHub issues for bugs and improvements. A maintainer will be keeping an eye on issues and PRs every day or three.

### Communication and Collaboration

We highly recommend that you join us in [slack](https://join.slack.com/t/rubyforgood/shared_invite/zt-21pyz2ab8-H6JgQfGGI0Ab6MfNOZRIQA) in the #casa channel so you can get fast help for any questions you may have.

Check out [our google calendar](https://bit.ly/casacal) to see when office hours and stakeholder meetings are.  

You can also open an issue or comment on an issue on GitHub and a maintainer will reply to you.

### About this project

CASA is a national organization with many regional chapters. We currently work with [Prince George's County CASA in Maryland](https://pgcasa.org/), [Montgomery CASA Maryland](https://casaspeaks4kids.com), and [Howard County Maryland](https://marylandcasa.org/programs/howard-county/)

This system provides value by:

- providing volunteers with a portal for logging activity
- allow supervisors to oversee volunteer activity
- generate reports on volunteer activity for admins to use in grant proposals

Read about the [product sense](doc/productsense.md) that guides our approach to this work.

**How CASA works:**

- A foster youth is represented as a **CASA case**.
- The **CASA case** is assigned to a **volunteer**.
- The **volunteer** records their efforts spent on the CASA case as **case contacts**.
- **Supervisors** oversee CASA **volunteers** by monitoring, tracking, and advising them on **CASA case** activities.
- At PG CASA, the minimum volunteer commitment is one year (this varies by CASA chapter, in San Francisco the minimum commitment is ~ two years).  A volunteer's  lifecycle is very long, so there's a lot of activity for chapters to organize.

**Project Considerations**

- PG CASA is operating under a very tight budget. Right now, they manually input volunteer data into [a volunteer management software built specifically for CASA](http://www.simplyoptima.com/), but upgrading their account for multiple user licenses to allow volunteers to self-log activity data is beyond their budget. Hence why we are building as lightweight a solution as possible that can sustain itself with Ruby for Good's support.
- While the scope of this platform's use is currently for PG County CASA and Montgomery county CASA, we are building with a mind toward multitenancy so this platform could prospectively be used by other CASA chapters across the country.

**More information:**

The complete [role description of a CASA volunteer](https://pgcasa.org/volunteer-description/) in Prince George's County.

# Developing! ✨🛠✨
## How to Contribute
  See our [contributing guide](./doc/CONTRIBUTING.md) 💖 ✨
## Installation

###  Getting Started (Codespaces - EXPERIMENTAL) 🛠️

[![Open in GitHub Codespaces](https://github.com/codespaces/badge.svg)](https://codespaces.new/rubyforgood/casa/tree/main?quickstart=1)

1. Follow the link above or follow instructions to [create a new Codespace.](https://docs.github.com/en/codespaces/developing-in-a-codespace/creating-a-codespace-for-a-repository); You can use the web editor, or even better open the Codespace in VSCode
2. Wait for the container to start. This will take a few (10-15) minutes since Ruby needs to be installed, the database needs to be created, and the `bin/setup` script needs to run
3. Run `bin/dev` and visit the URL that pops in VSCode up to see the CASA page
4. Login as a sample user with these default credentials (which also work for [QA](https://casa-qa.herokuapp.com/)):

### Local Setup Instructions
**Downloading the Project**
(*on a Mac or Linux machine*)
1. `git clone https://github.com/rubyforgood/casa.git` clone the repo to your local machine.
2. You can ask a [maintainer](https://github.com/rubyforgood/casa/wiki/Who's-who%3F) for permission to make a branch on this repo.
3. You can also [create a fork on GitHub](https://docs.github.com/en/get-started/quickstart/fork-a-repo) and make a pull request from the fork.

**Ruby**
1. Install a ruby version manager: [rvm](https://rvm.io/) or [rbenv](https://github.com/rbenv/rbenv)
1. when you cd into the project directory, let your version manager install the ruby version in `.ruby-version`. Right now that's Ruby 3.2.4
1. `gem install bundler`

**node.js**
1. (Recommended) Install [nvm](https://github.com/nvm-sh/nvm#installing-and-updating), which is a **n**ode **v**ersion **m**anager.
    - If you use asdf, the node version from `.tool-versions` will be used, but may be out of sync with the codename version (lts/iron) in `.nvmrc`. To use the version from `.nvmrc`, see one of these options: [legacy file codename support](https://github.com/asdf-vm/asdf-nodejs?tab=readme-ov-file#partial-and-codename-versions) or [installing via custom script](https://github.com/asdf-vm/asdf-nodejs/issues/382#issuecomment-2258647554).
1. Install a current LTS version of Node. Running `nvm install` from this directory will read the `.nvmrc` file to install the correct version.
1. Install [yarn](https://classic.yarnpkg.com/en/docs/install). On Ubuntu, [make sure you install it from the official Yarn repo instead of cmdtest](https://classic.yarnpkg.com/en/docs/install/#debian-stable).

**PostgreSQL ("postgres")**
1. Make sure that postgres is installed.
  - If you're on Ubuntu/WSL, use `sudo apt-get install libpq-dev` so the gem can install. [Use the Postgres repo for Ubuntu or WSL to get the server and client tools](https://www.postgresql.org/download/linux/ubuntu/).
  - If you're on Fedora/Cent Os use `sudo dnf install libpq-devel`. [If you prefer choose package of libpq-devel via rpm](https://pkgs.org/download/libpq-devel)
  - If you're on Windows, use the official [installer](https://www.postgresql.org/download/windows/) and accept all defaults.  Alternatively, a [Chocolatey](https://chocolatey.org/packages/postgresql) package is available with `choco install postgresql`.

**Chrome Browser**

1. The Spec tests uses Chrome Browser and Chromedriver for some of the tests. A current version of chromedriver will be installed when `bundle install` is run. TO install Chrome, see [Chrome Install](https://support.google.com/chrome/answer/95346?hl=en&ref_topic=7439538).

Another option is to install the Chromium browser for your operating system so the browser-based Ruby feature/integration tests can run. Installing `chromium-browser` is enough, including for many WSL (Windows subsystem for Linux) distributions.

If you are using Ubuntu on WSL and receive the following message when trying to run the test suite...

> Command '/usr/bin/chromium-browser' requires the chromium snap to be installed. Please install it with:
> `snap install chromium`

...check out the instructions on [installing google-chrome and chromedriver for WSL Ubuntu](https://github.com/rubyforgood/casa/blob/main/doc/WSL_SETUP.md#google-chrome).

### Platform Specific Installation Instructions
 - [Docker](doc/DOCKER.md)
 - [Linux](doc/LINUX_SETUP.md)
 - [Mac](doc/MAC_SETUP.md)
 - Windows(Help Wanted)
 - [Windows Subsystem for Linux(WSL)](https://github.com/rubyforgood/casa/blob/main/doc/WSL_SETUP.md)
 - [Nix](doc/NIX_SETUP.md)

### Common issues

1. If your rails/rake commands hang forever instead of running, try: `rails app:update:bin`
1. There is currently no option for a user to sign up and create an account through the UI. This is intentional. If you want to log in, use a pre-seeded user account and its credentials.
1. If you are on windows and see the error "Requirements support for mingw is not implemented yet" then use https://rubyinstaller.org/ instead
1. Install imagemagick to see images locally. Instructions: https://imagemagick.org/script/download.php
1. _If you are running on an M1 mac, run the following command before you start the installation process:_
   1. _Set the architecture_: `$env /usr/bin/arch -arm64 /bin/zsh ---login`
   1. _Remove all gems before you proceed_: `gem uninstall -aIx`
1. If `bin/setup` fails with a credentials error:
   1. Open the `.env` file.
   1. Update the values of `POSTGRES_USER` and `POSTGRES_PASSWORD`to match your PostgreSQL credentials.
   1. Run `bin/setup`

## Running the App / Verifying Installation
1. `cd casa/`
1. Run `bin/setup`
1. Run `bin/dev` and visit http://localhost:3000/ to see the app running.

**Logging in with seed users**

Login as a regular user at http://localhost:3000/users/sign_in. Some example seed users:
- volunteer1@example.com    view site as a volunteer
- supervisor1@example.com   view site as a supervisor
- casa_admin1@example.com   view site as an admin
- casa_admin2-1@example.com view site as admin from a different org

Login as an all CASA admin at http://localhost:3000/all_casa_admins/sign_in. An example seed user:
- allcasaadmin@example.com view site as an all CASA admin

The password for all seed users is `12345678`

**Local email**

We are using [Letter Opener](https://github.com/ryanb/letter_opener) in
development to receive mail. All emails sent in development should open in a
new tab in the browser.

To see local email previews, check out http://localhost:3000/rails/mailers

**Running Tests**
 - run the ruby test suite `bin/rails spec`
 - run the javascript test suite `yarn test`

If you have trouble running tests, check out CI scripts in [`.github/workflows/`](.github/workflows/) for sample commands.
Test coverage is run by simplecov on all builds and aggregated by CodeClimate

**Cleaning up before you pull request**

Run `bin/lint` to run all linters and fix issues. This will run:

1. `bundle exec standardrb --fix` auto-fix Ruby linting issues [more linter info](https://github.com/testdouble/standard)
1. `bundle exec erblint --lint-all --autocorrect` [ERB linter](https://github.com/Shopify/erb-lint)
1. `yarn lint:fix` to run the [JS linter](https://standardjs.com/index.html) and fix issues
1. `rake factory_bot:lint` if you have been editing factories and want to find factories and traits which produce invalid objects

If additional work arises from your pull request that is outside the scope of the issue it resolves, please open a new issue.

**Stimulus**

[Issue 5016](https://github.com/rubyforgood/casa/issues/5016) started a refactor of Javascript to use
[Hotwire's Stimulus](https://stimulus.hotwired.dev/handbook/origin). To see if it's working for you, go to
`/casa_cases` and see **Stimulus is working!** in your browser console.

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

# Other Documentation
Check out [the wiki](https://github.com/rubyforgood/casa/wiki)

There is a `doc` directory at the top level that includes:
* an `architecture-decisions` directory containing important architectural decisions and entity relationship diagrams of various models
  (see the article [Architectural Decision Records](http://thinkrelevance.com/blog/2011/11/15/documenting-architecture-decisions) describing this approach).
* [Code of Conduct](doc/code-of-conduct.md)
* [productsense.md](doc/productsense.md)(for team leads & product interested contributors)
* [SECURITY.md](doc/SECURITY.md)

# Acknowledgements

Thank you to [Scout](https://ter.li/h8k29r) for letting us use their dashboard for free!
[<img src="https://user-images.githubusercontent.com/578159/165240278-c2c0ac30-c86f-4b67-9da6-e6a5e4ab4c37.png" width="400" height="400" />](https://ter.li/h8k29r)

Join info for all public meetings is posted in the rubyforgood slack in the #casa channel

# Feedback

We are very interested in your feedback! Please give us some :) https://forms.gle/1D5ACNgTs2u9gSdh9
