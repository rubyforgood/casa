# CASA Project and Organization Overview

[![rspec](https://github.com/rubyforgood/casa/workflows/rspec/badge.svg)](https://github.com/rubyforgood/casa/actions/workflows/rspec.yml)
[![erb lint](https://github.com/rubyforgood/casa/actions/workflows/erb_lint.yml/badge.svg)](https://github.com/rubyforgood/casa/actions/workflows/erb_lint.yml)
[![standardrb lint](https://github.com/rubyforgood/casa/actions/workflows/ruby_lint.yml/badge.svg)](https://github.com/rubyforgood/casa/actions/workflows/ruby_lint.yml)
[![brakeman](https://github.com/rubyforgood/casa/workflows/brakeman/badge.svg)](https://github.com/rubyforgood/casa/actions/workflows/security.yml)
[![npm lint](https://github.com/rubyforgood/casa/actions/workflows/npm_lint_and_test.yml/badge.svg)](https://github.com/rubyforgood/casa/actions/workflows/npm_lint_and_test.yml)

[![Maintainability](https://api.codeclimate.com/v1/badges/24f3bb10db6afac417e2/maintainability)](https://codeclimate.com/github/rubyforgood/casa/trends/technical_debt)
[![Test Coverage](https://api.codeclimate.com/v1/badges/24f3bb10db6afac417e2/test_coverage)](https://codeclimate.com/github/rubyforgood/casa/trends/test_coverage_total)
[![Snyk Vulnerabilities](https://snyk.io/test/github/rubyforgood/casa/badge.svg)](https://snyk.io/test/github/rubyforgood/casa)
[![Average time to resolve an issue](http://isitmaintained.com/badge/resolution/rubyforgood/casa.svg)](http://isitmaintained.com/project/rubyforgood/casa "Average time to resolve an issue")

A CASA (Court Appointed Special Advocate) is a role where a volunteer advocates on behalf of a youth in their county's foster care system. CASA is also the namesake role of the national organization, CASA, which exists to cultivate and supervise volunteers carrying out this work – with county level chapters (operating relatively independently of each other) across the country.

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**

  - [Welcome contributors!](#welcome-contributors)
    - [Communication and Collaboration](#communication-and-collaboration)
    - [About this project](#about-this-project)
  - [Tech Stack](#tech-stack)
  - [Resources](#resources)
- [Developing!](#developing)
  - [How to Contribute](#how-to-contribute)
  - [Installation](#installation)
    - [Getting Started (Codespaces) 🛠️](#getting-started-codespaces-)
    - [Local Setup Instructions](#local-setup-instructions)
    - [Platform Specific Installation Instructions](#platform-specific-installation-instructions)
    - [Common issues](#common-issues)
  - [Running the App / Verifying Installation](#running-the-app--verifying-installation)
    - [QA Environment](#qa-environment)
    - [Logging in with seed users](#logging-in-with-seed-users)
    - [Local email](#local-email)
    - [Running Tests](#running-tests)
    - [Cleaning up before you pull request](#cleaning-up-before-you-pull-request)
    - [Frontend Architecture](#frontend-architecture)
  - [Keeping Your Local Environment Up to Date](#keeping-your-local-environment-up-to-date)
- [Contributors](#contributors)
- [Other Documentation](#other-documentation)
- [Acknowledgements](#acknowledgements)
- [Feedback](#feedback)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## Welcome contributors!

We are very happy to have you! CASA and Ruby for Good are committed to welcoming new contributors of all skill levels.

Find issues to work on [here](https://github.com/rubyforgood/casa/issues?q=is%3Aissue+is%3Aopen+no%3Aassignee) on the issue board. Issues on the [project's](https://github.com/rubyforgood/casa/projects/1) TODO column are another way to browse issues. Check to see that no one is assigned to the issue. Then comment on it to claim the issue. Commenting on an issue doesn't automatically get the issue assigned so double check the comments on an issue to see that no one is requesting assignment.

Pull requests which are not for an issue but which improve the codebase are also welcome! Feel free to make GitHub issues for bugs and improvements. A maintainer will be keeping an eye on issues and PRs every day or three.

### Communication and Collaboration

We highly recommend that you join us in [slack](https://join.slack.com/t/rubyforgood/shared_invite/zt-34b5p4vk3-NWIw6hKs2ma~wm7mYSe0_A) in the #casa channel so you can get fast help for any questions you may have.

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

## Tech Stack

| Technology | Version |
|---|---|
| Ruby | 4.0.3 (see `.ruby-version`) |
| Rails | 7.2 |
| PostgreSQL | 14+ |
| Node.js | LTS/Krypton (see `.nvmrc`) |

Key libraries: [Hotwire Turbo](https://turbo.hotwired.dev/), [Stimulus](https://stimulus.hotwired.dev/), [RSpec](https://rspec.info/), [StandardRB](https://github.com/standardrb/standard)

## Resources

- [Architecture decisions](doc/architecture-decisions/) — ADRs explaining key technical choices and entity relationship diagrams
- [DB diagram](doc/db_diagram_schema_code/) — import `schema.rb` into [dbdiagram.io](https://dbdiagram.io/d) for a live model diagram
- [Product sense](doc/productsense.md) — mission and product philosophy (recommended reading for leads and product contributors)
- [Wiki](https://github.com/rubyforgood/casa/wiki) — additional guides and who's who
- [Google Calendar](https://bit.ly/casacal) — office hours and stakeholder meetings

# Developing!
## How to Contribute
  See our [contributing guide](./doc/CONTRIBUTING.md) 💖 ✨
## Installation

###  Getting Started (Codespaces) 🛠️

[![Open in GitHub Codespaces](https://github.com/codespaces/badge.svg)](https://codespaces.new/rubyforgood/casa/tree/main?quickstart=1)

1. Follow the link above or follow instructions to [create a new Codespace.](https://docs.github.com/en/codespaces/developing-in-a-codespace/creating-a-codespace-for-a-repository); You can use the web editor, or even better open the Codespace in VSCode
2. Wait for the container to start. This will take a few (10-15) minutes since Ruby needs to be installed, the database needs to be created, and the `bin/setup` script needs to run
3. Run `bin/dev` and visit the URL that pops in VSCode up to see the CASA page
4. Login as a sample user — see [Logging in with seed users](#logging-in-with-seed-users) for credentials (the same credentials also work on the [QA environment](#qa-environment))

### Local Setup Instructions
**Downloading the Project**
(*on a Mac or Linux machine*)
1. `git clone https://github.com/rubyforgood/casa.git` clone the repo to your local machine.
2. You can ask a [maintainer](https://github.com/rubyforgood/casa/wiki/Who's-who%3F) for permission to make a branch on this repo.
3. You can also [create a fork on GitHub](https://docs.github.com/en/get-started/quickstart/fork-a-repo) and make a pull request from the fork.

**Ruby**
1. Install a ruby version manager: [rvm](https://rvm.io/) or [rbenv](https://github.com/rbenv/rbenv)
1. when you cd into the project directory, let your version manager install the ruby version in `.ruby-version`. Right now that's Ruby 4.0.3
1. `gem install bundler`

**node.js**
1. (Recommended) Install [nvm](https://github.com/nvm-sh/nvm#installing-and-updating), which is a **n**ode **v**ersion **m**anager.
    - If you use asdf, the node version from `.tool-versions` will be used, but may be out of sync with the codename version in `.nvmrc`. To use the version from `.nvmrc`, see one of these options: [legacy file codename support](https://github.com/asdf-vm/asdf-nodejs?tab=readme-ov-file#partial-and-codename-versions) or [installing via custom script](https://github.com/asdf-vm/asdf-nodejs/issues/382#issuecomment-2258647554).
1. Install a current LTS version of Node. Running `nvm install` from this directory will read the `.nvmrc` file to install the correct version.

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
 - Windows — see the [WSL setup guide](doc/WSL_SETUP.md) for the recommended Windows path
 - [Windows Subsystem for Linux (WSL)](https://github.com/rubyforgood/casa/blob/main/doc/WSL_SETUP.md)
 - [Nix](doc/NIX_SETUP.md)

### Common issues

<details>
<summary>Rails/rake commands hang forever instead of running</summary>

Run: `rails app:update:bin`
</details>

<details>
<summary>No option for a user to sign up through the UI</summary>

This is intentional. Use a pre-seeded user account — see [Logging in with seed users](#logging-in-with-seed-users).
</details>

<details>
<summary>Windows error: "Requirements support for mingw is not implemented yet"</summary>

Use [RubyInstaller](https://rubyinstaller.org/) instead.
</details>

<details>
<summary>Images not displaying locally</summary>

Install imagemagick: https://imagemagick.org/script/download.php
</details>

<details>
<summary>M1 Mac installation issues</summary>

Run these commands before starting the installation process:

1. Set the architecture: `$env /usr/bin/arch -arm64 /bin/zsh ---login`
2. Remove all gems: `gem uninstall -aIx`
</details>

<details>
<summary>bin/setup fails with a credentials error</summary>

1. Open the `.env` file.
2. Update `POSTGRES_USER` and `POSTGRES_PASSWORD` to match your PostgreSQL credentials.
3. Run `bin/setup`
</details>

## Running the App / Verifying Installation
1. `cd casa/`
1. Run `bin/setup`
1. Run `bin/dev` and visit http://localhost:3000/ to see the app running.

### QA Environment

A publicly accessible QA environment is available at **https://casa-qa.herokuapp.com/**. You can log in using the same seed credentials below — useful for exploring the app without any local setup.

### Logging in with seed users

**Local:** http://localhost:3000/users/sign_in — **QA:** https://casa-qa.herokuapp.com/users/sign_in

| Email | Role | Password |
|---|---|---|
| volunteer1@example.com | Volunteer | 12345678 |
| supervisor1@example.com | Supervisor | 12345678 |
| casa_admin1@example.com | Admin | 12345678 |
| casa_admin2-1@example.com | Admin (different org) | 12345678 |

All CASA admin login at http://localhost:3000/all_casa_admins/sign_in (QA: https://casa-qa.herokuapp.com/all_casa_admins/sign_in):

| Email | Role | Password |
|---|---|---|
| allcasaadmin@example.com | All CASA Admin | 12345678 |

### Local email

We are using [Letter Opener](https://github.com/ryanb/letter_opener) in
development to receive mail. All emails sent in development should open in a
new tab in the browser.

To see local email previews, check out http://localhost:3000/rails/mailers

### Running Tests
 - run the ruby test suite `bin/rails spec`
 - run the javascript test suite `npm run test`

If you have trouble running tests, check out CI scripts in [`.github/workflows/`](.github/workflows/) for sample commands.
Test coverage is run by simplecov on all builds and aggregated by CodeClimate

### Cleaning up before you pull request

Run `bin/lint` to run all linters and fix issues. This will run:

1. `bundle exec standardrb --fix` auto-fix Ruby linting issues [more linter info](https://github.com/testdouble/standard)
1. `bundle exec erb_lint --lint-all --autocorrect` [ERB linter](https://github.com/Shopify/erb-lint)
1. `npm run lint:fix` to run the [JS linter](https://standardjs.com/index.html) and fix issues
1. `rake factory_bot:lint` if you have been editing factories and want to find factories and traits which produce invalid objects

If additional work arises from your pull request that is outside the scope of the issue it resolves, please open a new issue.

### Frontend Architecture

The frontend uses [Hotwire](https://hotwired.dev/) — specifically [Turbo](https://turbo.hotwired.dev/) for page navigation and form handling, and [Stimulus](https://stimulus.hotwired.dev/) for lightweight JavaScript controllers attached to DOM elements.

[Issue 5016](https://github.com/rubyforgood/casa/issues/5016) tracks the ongoing migration from inline JavaScript to Stimulus. Stimulus controllers live in `app/javascript/controllers/`. To verify Stimulus is working in your local environment, navigate to `/casa_cases` and check your browser console for **Stimulus is working!**

## Keeping Your Local Environment Up to Date

After pulling new changes from `main`, run:
```
bin/update
```

This runs any pending database migrations, updates gems and node packages, and executes post-deployment tasks in one step.

**Post-deployment tasks**

We use [After Party](https://github.com/theSteveMitchell/after_party) for post-deployment tasks that may include one-time database updates. To run them manually:
```
bundle exec rake after_party:run
```

# Contributors

We welcome contributions of all kinds! To request attribution for your work, comment on your pull request with:

```
@all-contributors please add @<username> for <contributions>.
```

Replace `<contributions>` with `code`, `review`, `doc`, `bug`, or see the [emoji key](https://allcontributors.org/docs/en/emoji-key) for all contribution types.

<!-- ALL-CONTRIBUTORS-LIST:START - Do not remove or modify this section -->
<!-- prettier-ignore-start -->
<!-- markdownlint-disable -->
<table>
  <tbody>
    <tr>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/compwron"><img src="https://avatars.githubusercontent.com/u/578159?v=4?s=100" width="100px;" alt="compwron"/><br /><sub><b>compwron</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=compwron" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/FireLemons"><img src="https://avatars.githubusercontent.com/u/8918762?v=4?s=100" width="100px;" alt="FireLemons"/><br /><sub><b>FireLemons</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=FireLemons" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/littleforest"><img src="https://avatars.githubusercontent.com/u/1938665?v=4?s=100" width="100px;" alt="littleforest"/><br /><sub><b>littleforest</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=littleforest" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/xihai01"><img src="https://avatars.githubusercontent.com/u/86758440?v=4?s=100" width="100px;" alt="xihai01"/><br /><sub><b>xihai01</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=xihai01" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/librod89"><img src="https://avatars.githubusercontent.com/u/4965672?v=4?s=100" width="100px;" alt="librod89"/><br /><sub><b>librod89</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=librod89" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/efgalvao"><img src="https://avatars.githubusercontent.com/u/61836657?v=4?s=100" width="100px;" alt="efgalvao"/><br /><sub><b>efgalvao</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=efgalvao" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/DrewAPeterson7671"><img src="https://avatars.githubusercontent.com/u/52431336?v=4?s=100" width="100px;" alt="DrewAPeterson7671"/><br /><sub><b>DrewAPeterson7671</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=DrewAPeterson7671" title="Code">💻</a></td>
    </tr>
    <tr>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/seanmarcia"><img src="https://avatars.githubusercontent.com/u/667909?v=4?s=100" width="100px;" alt="seanmarcia"/><br /><sub><b>seanmarcia</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=seanmarcia" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/harsohailB"><img src="https://avatars.githubusercontent.com/u/47438886?v=4?s=100" width="100px;" alt="harsohailB"/><br /><sub><b>harsohailB</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=harsohailB" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/mussajoop"><img src="https://avatars.githubusercontent.com/u/25673850?v=4?s=100" width="100px;" alt="mussajoop"/><br /><sub><b>mussajoop</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=mussajoop" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/ErinClaudio"><img src="https://avatars.githubusercontent.com/u/20326770?v=4?s=100" width="100px;" alt="ErinClaudio"/><br /><sub><b>ErinClaudio</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=ErinClaudio" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/crespire"><img src="https://avatars.githubusercontent.com/u/36272822?v=4?s=100" width="100px;" alt="crespire"/><br /><sub><b>crespire</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=crespire" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/ShamiTomita"><img src="https://avatars.githubusercontent.com/u/70528966?v=4?s=100" width="100px;" alt="ShamiTomita"/><br /><sub><b>ShamiTomita</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=ShamiTomita" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/7riumph"><img src="https://avatars.githubusercontent.com/u/58965520?v=4?s=100" width="100px;" alt="7riumph"/><br /><sub><b>7riumph</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=7riumph" title="Code">💻</a></td>
    </tr>
    <tr>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/AudTheCodeWitch"><img src="https://avatars.githubusercontent.com/u/51171867?v=4?s=100" width="100px;" alt="AudTheCodeWitch"/><br /><sub><b>AudTheCodeWitch</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=AudTheCodeWitch" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/colinsoleim"><img src="https://avatars.githubusercontent.com/u/1221519?v=4?s=100" width="100px;" alt="colinsoleim"/><br /><sub><b>colinsoleim</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=colinsoleim" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/vasconsaurus"><img src="https://avatars.githubusercontent.com/u/87862340?v=4?s=100" width="100px;" alt="vasconsaurus"/><br /><sub><b>vasconsaurus</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=vasconsaurus" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/thejonroberts"><img src="https://avatars.githubusercontent.com/u/28872849?v=4?s=100" width="100px;" alt="thejonroberts"/><br /><sub><b>thejonroberts</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=thejonroberts" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/elasticspoon"><img src="https://avatars.githubusercontent.com/u/14540596?v=4?s=100" width="100px;" alt="elasticspoon"/><br /><sub><b>elasticspoon</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=elasticspoon" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/rhian-cs"><img src="https://avatars.githubusercontent.com/u/72531802?v=4?s=100" width="100px;" alt="rhian-cs"/><br /><sub><b>rhian-cs</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=rhian-cs" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/jmkoni"><img src="https://avatars.githubusercontent.com/u/1082370?v=4?s=100" width="100px;" alt="jmkoni"/><br /><sub><b>jmkoni</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=jmkoni" title="Code">💻</a></td>
    </tr>
    <tr>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/elhalvers"><img src="https://avatars.githubusercontent.com/u/74928397?v=4?s=100" width="100px;" alt="elhalvers"/><br /><sub><b>elhalvers</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=elhalvers" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/scottolsen"><img src="https://avatars.githubusercontent.com/u/113754?v=4?s=100" width="100px;" alt="scottolsen"/><br /><sub><b>scottolsen</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=scottolsen" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/Learningstuff98"><img src="https://avatars.githubusercontent.com/u/42154066?v=4?s=100" width="100px;" alt="Learningstuff98"/><br /><sub><b>Learningstuff98</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=Learningstuff98" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/keithrbennett"><img src="https://avatars.githubusercontent.com/u/28410?v=4?s=100" width="100px;" alt="keithrbennett"/><br /><sub><b>keithrbennett</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=keithrbennett" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/cliftonmcintosh"><img src="https://avatars.githubusercontent.com/u/3824492?v=4?s=100" width="100px;" alt="cliftonmcintosh"/><br /><sub><b>cliftonmcintosh</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=cliftonmcintosh" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/aedwardg"><img src="https://avatars.githubusercontent.com/u/44326005?v=4?s=100" width="100px;" alt="aedwardg"/><br /><sub><b>aedwardg</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=aedwardg" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/marmitoTH"><img src="https://avatars.githubusercontent.com/u/25598040?v=4?s=100" width="100px;" alt="marmitoTH"/><br /><sub><b>marmitoTH</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=marmitoTH" title="Code">💻</a></td>
    </tr>
    <tr>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/pollygee"><img src="https://avatars.githubusercontent.com/u/10904005?v=4?s=100" width="100px;" alt="pollygee"/><br /><sub><b>pollygee</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=pollygee" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/stefannibrasil"><img src="https://avatars.githubusercontent.com/u/10670581?v=4?s=100" width="100px;" alt="stefannibrasil"/><br /><sub><b>stefannibrasil</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=stefannibrasil" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/Garbar"><img src="https://avatars.githubusercontent.com/u/1007159?v=4?s=100" width="100px;" alt="Garbar"/><br /><sub><b>Garbar</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=Garbar" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/erik-trantt"><img src="https://avatars.githubusercontent.com/u/44339322?v=4?s=100" width="100px;" alt="erik-trantt"/><br /><sub><b>erik-trantt</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=erik-trantt" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/Thrillberg"><img src="https://avatars.githubusercontent.com/u/10481391?v=4?s=100" width="100px;" alt="Thrillberg"/><br /><sub><b>Thrillberg</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=Thrillberg" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/sarvaiyanidhi"><img src="https://avatars.githubusercontent.com/u/514363?v=4?s=100" width="100px;" alt="sarvaiyanidhi"/><br /><sub><b>sarvaiyanidhi</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=sarvaiyanidhi" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/amygurski"><img src="https://avatars.githubusercontent.com/u/49253356?v=4?s=100" width="100px;" alt="amygurski"/><br /><sub><b>amygurski</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=amygurski" title="Code">💻</a></td>
    </tr>
    <tr>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/schoork"><img src="https://avatars.githubusercontent.com/u/50247514?v=4?s=100" width="100px;" alt="schoork"/><br /><sub><b>schoork</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=schoork" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/armahillo"><img src="https://avatars.githubusercontent.com/u/502363?v=4?s=100" width="100px;" alt="armahillo"/><br /><sub><b>armahillo</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=armahillo" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/hairedfox"><img src="https://avatars.githubusercontent.com/u/42526152?v=4?s=100" width="100px;" alt="hairedfox"/><br /><sub><b>hairedfox</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=hairedfox" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/ryanmrodriguez"><img src="https://avatars.githubusercontent.com/u/62253265?v=4?s=100" width="100px;" alt="ryanmrodriguez"/><br /><sub><b>ryanmrodriguez</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=ryanmrodriguez" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/gmfvpereira"><img src="https://avatars.githubusercontent.com/u/386460?v=4?s=100" width="100px;" alt="gmfvpereira"/><br /><sub><b>gmfvpereira</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=gmfvpereira" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/jesselasalle"><img src="https://avatars.githubusercontent.com/u/4956537?v=4?s=100" width="100px;" alt="jesselasalle"/><br /><sub><b>jesselasalle</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=jesselasalle" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/arthur1041"><img src="https://avatars.githubusercontent.com/u/42497300?v=4?s=100" width="100px;" alt="arthur1041"/><br /><sub><b>arthur1041</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=arthur1041" title="Code">💻</a></td>
    </tr>
    <tr>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/carrollsa"><img src="https://avatars.githubusercontent.com/u/76665107?v=4?s=100" width="100px;" alt="carrollsa"/><br /><sub><b>carrollsa</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=carrollsa" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/caitmich"><img src="https://avatars.githubusercontent.com/u/78065527?v=4?s=100" width="100px;" alt="caitmich"/><br /><sub><b>caitmich</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=caitmich" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/LeGorge"><img src="https://avatars.githubusercontent.com/u/15731175?v=4?s=100" width="100px;" alt="LeGorge"/><br /><sub><b>LeGorge</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=LeGorge" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/abachman"><img src="https://avatars.githubusercontent.com/u/13002?v=4?s=100" width="100px;" alt="abachman"/><br /><sub><b>abachman</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=abachman" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/codewithjulie"><img src="https://avatars.githubusercontent.com/u/70556962?v=4?s=100" width="100px;" alt="codewithjulie"/><br /><sub><b>codewithjulie</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=codewithjulie" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/MikeRose151"><img src="https://avatars.githubusercontent.com/u/72466799?v=4?s=100" width="100px;" alt="MikeRose151"/><br /><sub><b>MikeRose151</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=MikeRose151" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/casadei"><img src="https://avatars.githubusercontent.com/u/938522?v=4?s=100" width="100px;" alt="casadei"/><br /><sub><b>casadei</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=casadei" title="Code">💻</a></td>
    </tr>
    <tr>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/aboongm"><img src="https://avatars.githubusercontent.com/u/49184579?v=4?s=100" width="100px;" alt="aboongm"/><br /><sub><b>aboongm</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=aboongm" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/dpaola2"><img src="https://avatars.githubusercontent.com/u/150509?v=4?s=100" width="100px;" alt="dpaola2"/><br /><sub><b>dpaola2</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=dpaola2" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/internetroger"><img src="https://avatars.githubusercontent.com/u/5456014?v=4?s=100" width="100px;" alt="internetroger"/><br /><sub><b>internetroger</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=internetroger" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/roxannecojocariu"><img src="https://avatars.githubusercontent.com/u/35009869?v=4?s=100" width="100px;" alt="roxannecojocariu"/><br /><sub><b>roxannecojocariu</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=roxannecojocariu" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/patrickarnett"><img src="https://avatars.githubusercontent.com/u/29066220?v=4?s=100" width="100px;" alt="patrickarnett"/><br /><sub><b>patrickarnett</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=patrickarnett" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/andrew-k9"><img src="https://avatars.githubusercontent.com/u/20051541?v=4?s=100" width="100px;" alt="andrew-k9"/><br /><sub><b>andrew-k9</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=andrew-k9" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/alindeman"><img src="https://avatars.githubusercontent.com/u/395621?v=4?s=100" width="100px;" alt="alindeman"/><br /><sub><b>alindeman</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=alindeman" title="Code">💻</a></td>
    </tr>
    <tr>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/nehaabraham"><img src="https://avatars.githubusercontent.com/u/8978311?v=4?s=100" width="100px;" alt="nehaabraham"/><br /><sub><b>nehaabraham</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=nehaabraham" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/alex-yi37"><img src="https://avatars.githubusercontent.com/u/87381690?v=4?s=100" width="100px;" alt="alex-yi37"/><br /><sub><b>alex-yi37</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=alex-yi37" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/MclPio"><img src="https://avatars.githubusercontent.com/u/113801014?v=4?s=100" width="100px;" alt="MclPio"/><br /><sub><b>MclPio</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=MclPio" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/cam-benfield"><img src="https://avatars.githubusercontent.com/u/33261934?v=4?s=100" width="100px;" alt="cam-benfield"/><br /><sub><b>cam-benfield</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=cam-benfield" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/cjilbert504"><img src="https://avatars.githubusercontent.com/u/54157657?v=4?s=100" width="100px;" alt="cjilbert504"/><br /><sub><b>cjilbert504</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=cjilbert504" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/drborges"><img src="https://avatars.githubusercontent.com/u/508128?v=4?s=100" width="100px;" alt="drborges"/><br /><sub><b>drborges</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=drborges" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/metamoni"><img src="https://avatars.githubusercontent.com/u/22390758?v=4?s=100" width="100px;" alt="metamoni"/><br /><sub><b>metamoni</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=metamoni" title="Code">💻</a></td>
    </tr>
    <tr>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/PuZZleDucK"><img src="https://avatars.githubusercontent.com/u/1674861?v=4?s=100" width="100px;" alt="PuZZleDucK"/><br /><sub><b>PuZZleDucK</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=PuZZleDucK" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/AravindSelvamani"><img src="https://avatars.githubusercontent.com/u/39373592?v=4?s=100" width="100px;" alt="AravindSelvamani"/><br /><sub><b>AravindSelvamani</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=AravindSelvamani" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/jp524"><img src="https://avatars.githubusercontent.com/u/85654561?v=4?s=100" width="100px;" alt="jp524"/><br /><sub><b>jp524</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=jp524" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/guswhitten"><img src="https://avatars.githubusercontent.com/u/90280763?v=4?s=100" width="100px;" alt="guswhitten"/><br /><sub><b>guswhitten</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=guswhitten" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/llewis-ut"><img src="https://avatars.githubusercontent.com/u/139768581?v=4?s=100" width="100px;" alt="llewis-ut"/><br /><sub><b>llewis-ut</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=llewis-ut" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/rpolley"><img src="https://avatars.githubusercontent.com/u/23124989?v=4?s=100" width="100px;" alt="rpolley"/><br /><sub><b>rpolley</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=rpolley" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/lisavogtsf"><img src="https://avatars.githubusercontent.com/u/7121497?v=4?s=100" width="100px;" alt="lisavogtsf"/><br /><sub><b>lisavogtsf</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=lisavogtsf" title="Code">💻</a></td>
    </tr>
    <tr>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/fchagasjr"><img src="https://avatars.githubusercontent.com/u/79976550?v=4?s=100" width="100px;" alt="fchagasjr"/><br /><sub><b>fchagasjr</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=fchagasjr" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/hatsu38"><img src="https://avatars.githubusercontent.com/u/16137809?v=4?s=100" width="100px;" alt="hatsu38"/><br /><sub><b>hatsu38</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=hatsu38" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/italomatos"><img src="https://avatars.githubusercontent.com/u/836472?v=4?s=100" width="100px;" alt="italomatos"/><br /><sub><b>italomatos</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=italomatos" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/dominiquecuevas"><img src="https://avatars.githubusercontent.com/u/56096225?v=4?s=100" width="100px;" alt="dominiquecuevas"/><br /><sub><b>dominiquecuevas</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=dominiquecuevas" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/ciaranc78"><img src="https://avatars.githubusercontent.com/u/3953492?v=4?s=100" width="100px;" alt="ciaranc78"/><br /><sub><b>ciaranc78</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=ciaranc78" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/haydenrou"><img src="https://avatars.githubusercontent.com/u/21108297?v=4?s=100" width="100px;" alt="haydenrou"/><br /><sub><b>haydenrou</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=haydenrou" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/afogel"><img src="https://avatars.githubusercontent.com/u/2447409?v=4?s=100" width="100px;" alt="afogel"/><br /><sub><b>afogel</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=afogel" title="Code">💻</a></td>
    </tr>
    <tr>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/exgin"><img src="https://avatars.githubusercontent.com/u/59214236?v=4?s=100" width="100px;" alt="exgin"/><br /><sub><b>exgin</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=exgin" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/tundal45"><img src="https://avatars.githubusercontent.com/u/59220?v=4?s=100" width="100px;" alt="tundal45"/><br /><sub><b>tundal45</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=tundal45" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/marc"><img src="https://avatars.githubusercontent.com/u/725?v=4?s=100" width="100px;" alt="marc"/><br /><sub><b>marc</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=marc" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/andreLumor"><img src="https://avatars.githubusercontent.com/u/36737050?v=4?s=100" width="100px;" alt="andreLumor"/><br /><sub><b>andreLumor</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=andreLumor" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/johncarlocerna"><img src="https://avatars.githubusercontent.com/u/22579050?v=4?s=100" width="100px;" alt="johncarlocerna"/><br /><sub><b>johncarlocerna</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=johncarlocerna" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/ThomasNathan"><img src="https://avatars.githubusercontent.com/u/36716004?v=4?s=100" width="100px;" alt="ThomasNathan"/><br /><sub><b>ThomasNathan</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=ThomasNathan" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/matisnape"><img src="https://avatars.githubusercontent.com/u/2719923?v=4?s=100" width="100px;" alt="matisnape"/><br /><sub><b>matisnape</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=matisnape" title="Code">💻</a></td>
    </tr>
    <tr>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/NickSchimek"><img src="https://avatars.githubusercontent.com/u/19519317?v=4?s=100" width="100px;" alt="NickSchimek"/><br /><sub><b>NickSchimek</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=NickSchimek" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/tonyaraujop"><img src="https://avatars.githubusercontent.com/u/92229784?v=4?s=100" width="100px;" alt="tonyaraujop"/><br /><sub><b>tonyaraujop</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=tonyaraujop" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/cliiint"><img src="https://avatars.githubusercontent.com/u/51330983?v=4?s=100" width="100px;" alt="cliiint"/><br /><sub><b>cliiint</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=cliiint" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/DeadlockDruid"><img src="https://avatars.githubusercontent.com/u/13817656?v=4?s=100" width="100px;" alt="DeadlockDruid"/><br /><sub><b>DeadlockDruid</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=DeadlockDruid" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/KatherineMuedas"><img src="https://avatars.githubusercontent.com/u/6829115?v=4?s=100" width="100px;" alt="KatherineMuedas"/><br /><sub><b>KatherineMuedas</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=KatherineMuedas" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/Rafael-Martins"><img src="https://avatars.githubusercontent.com/u/27746333?v=4?s=100" width="100px;" alt="Rafael-Martins"/><br /><sub><b>Rafael-Martins</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=Rafael-Martins" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/geeksilva97"><img src="https://avatars.githubusercontent.com/u/15680379?v=4?s=100" width="100px;" alt="geeksilva97"/><br /><sub><b>geeksilva97</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=geeksilva97" title="Code">💻</a></td>
    </tr>
    <tr>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/mecastelom"><img src="https://avatars.githubusercontent.com/u/2204448?v=4?s=100" width="100px;" alt="mecastelom"/><br /><sub><b>mecastelom</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=mecastelom" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/iamronakgupta"><img src="https://avatars.githubusercontent.com/u/75837235?v=4?s=100" width="100px;" alt="iamronakgupta"/><br /><sub><b>iamronakgupta</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=iamronakgupta" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/freestylebit"><img src="https://avatars.githubusercontent.com/u/16199259?v=4?s=100" width="100px;" alt="freestylebit"/><br /><sub><b>freestylebit</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=freestylebit" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/joaovitoras"><img src="https://avatars.githubusercontent.com/u/6165892?v=4?s=100" width="100px;" alt="joaovitoras"/><br /><sub><b>joaovitoras</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=joaovitoras" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/albertchae"><img src="https://avatars.githubusercontent.com/u/217050?v=4?s=100" width="100px;" alt="albertchae"/><br /><sub><b>albertchae</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=albertchae" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/bjthompson805"><img src="https://avatars.githubusercontent.com/u/40772561?v=4?s=100" width="100px;" alt="bjthompson805"/><br /><sub><b>bjthompson805</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=bjthompson805" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/ashwinisukale"><img src="https://avatars.githubusercontent.com/u/1137325?v=4?s=100" width="100px;" alt="ashwinisukale"/><br /><sub><b>ashwinisukale</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=ashwinisukale" title="Code">💻</a></td>
    </tr>
    <tr>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/RobGentile17"><img src="https://avatars.githubusercontent.com/u/84338865?v=4?s=100" width="100px;" alt="RobGentile17"/><br /><sub><b>RobGentile17</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=RobGentile17" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/scantisani-ut"><img src="https://avatars.githubusercontent.com/u/136822170?v=4?s=100" width="100px;" alt="scantisani-ut"/><br /><sub><b>scantisani-ut</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=scantisani-ut" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/GALTdea"><img src="https://avatars.githubusercontent.com/u/16809030?v=4?s=100" width="100px;" alt="GALTdea"/><br /><sub><b>GALTdea</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=GALTdea" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/rae-stanton"><img src="https://avatars.githubusercontent.com/u/101673900?v=4?s=100" width="100px;" alt="rae-stanton"/><br /><sub><b>rae-stanton</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=rae-stanton" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/dominiclizarraga"><img src="https://avatars.githubusercontent.com/u/70678718?v=4?s=100" width="100px;" alt="dominiclizarraga"/><br /><sub><b>dominiclizarraga</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=dominiclizarraga" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/acrosman"><img src="https://avatars.githubusercontent.com/u/2972053?v=4?s=100" width="100px;" alt="acrosman"/><br /><sub><b>acrosman</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=acrosman" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/alanparmenter"><img src="https://avatars.githubusercontent.com/u/29056063?v=4?s=100" width="100px;" alt="alanparmenter"/><br /><sub><b>alanparmenter</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=alanparmenter" title="Code">💻</a></td>
    </tr>
    <tr>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/lisale0"><img src="https://avatars.githubusercontent.com/u/25441869?v=4?s=100" width="100px;" alt="lisale0"/><br /><sub><b>lisale0</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=lisale0" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/danaguilar"><img src="https://avatars.githubusercontent.com/u/3720420?v=4?s=100" width="100px;" alt="danaguilar"/><br /><sub><b>danaguilar</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=danaguilar" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/davidgumberg"><img src="https://avatars.githubusercontent.com/u/2257631?v=4?s=100" width="100px;" alt="davidgumberg"/><br /><sub><b>davidgumberg</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=davidgumberg" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/ginasekhar"><img src="https://avatars.githubusercontent.com/u/49568231?v=4?s=100" width="100px;" alt="ginasekhar"/><br /><sub><b>ginasekhar</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=ginasekhar" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/FeminismIsAwesome"><img src="https://avatars.githubusercontent.com/u/5641692?v=4?s=100" width="100px;" alt="FeminismIsAwesome"/><br /><sub><b>FeminismIsAwesome</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=FeminismIsAwesome" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/josephmsmith"><img src="https://avatars.githubusercontent.com/u/121319535?v=4?s=100" width="100px;" alt="josephmsmith"/><br /><sub><b>josephmsmith</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=josephmsmith" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/acasarsa"><img src="https://avatars.githubusercontent.com/u/17803351?v=4?s=100" width="100px;" alt="acasarsa"/><br /><sub><b>acasarsa</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=acasarsa" title="Code">💻</a></td>
    </tr>
    <tr>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/SajjadAhmad14"><img src="https://avatars.githubusercontent.com/u/35504149?v=4?s=100" width="100px;" alt="SajjadAhmad14"/><br /><sub><b>SajjadAhmad14</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=SajjadAhmad14" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/josearmandojacq"><img src="https://avatars.githubusercontent.com/u/24357305?v=4?s=100" width="100px;" alt="josearmandojacq"/><br /><sub><b>josearmandojacq</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=josearmandojacq" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/ycorredius"><img src="https://avatars.githubusercontent.com/u/33139203?v=4?s=100" width="100px;" alt="ycorredius"/><br /><sub><b>ycorredius</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=ycorredius" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/tamara-builds"><img src="https://avatars.githubusercontent.com/u/67713820?v=4?s=100" width="100px;" alt="tamara-builds"/><br /><sub><b>tamara-builds</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=tamara-builds" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/trevor-jameson"><img src="https://avatars.githubusercontent.com/u/19979089?v=4?s=100" width="100px;" alt="trevor-jameson"/><br /><sub><b>trevor-jameson</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=trevor-jameson" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/arku"><img src="https://avatars.githubusercontent.com/u/7039523?v=4?s=100" width="100px;" alt="arku"/><br /><sub><b>arku</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=arku" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/Salanoid"><img src="https://avatars.githubusercontent.com/u/16540719?v=4?s=100" width="100px;" alt="Salanoid"/><br /><sub><b>Salanoid</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=Salanoid" title="Code">💻</a></td>
    </tr>
    <tr>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/hiendinhngoc"><img src="https://avatars.githubusercontent.com/u/6258714?v=4?s=100" width="100px;" alt="hiendinhngoc"/><br /><sub><b>hiendinhngoc</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=hiendinhngoc" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/zspencer"><img src="https://avatars.githubusercontent.com/u/50284?v=4?s=100" width="100px;" alt="zspencer"/><br /><sub><b>zspencer</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=zspencer" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/sandfortw"><img src="https://avatars.githubusercontent.com/u/80081206?v=4?s=100" width="100px;" alt="sandfortw"/><br /><sub><b>sandfortw</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=sandfortw" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/BrianBorge"><img src="https://avatars.githubusercontent.com/u/6352760?v=4?s=100" width="100px;" alt="BrianBorge"/><br /><sub><b>BrianBorge</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=BrianBorge" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/fchatterji"><img src="https://avatars.githubusercontent.com/u/9966978?v=4?s=100" width="100px;" alt="fchatterji"/><br /><sub><b>fchatterji</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=fchatterji" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/carolyn-manning"><img src="https://avatars.githubusercontent.com/u/70597815?v=4?s=100" width="100px;" alt="carolyn-manning"/><br /><sub><b>carolyn-manning</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=carolyn-manning" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/ptrela"><img src="https://avatars.githubusercontent.com/u/56597310?v=4?s=100" width="100px;" alt="ptrela"/><br /><sub><b>ptrela</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=ptrela" title="Code">💻</a></td>
    </tr>
    <tr>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/Zrrrpy"><img src="https://avatars.githubusercontent.com/u/62810851?v=4?s=100" width="100px;" alt="Zrrrpy"/><br /><sub><b>Zrrrpy</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=Zrrrpy" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/ChaelCodes"><img src="https://avatars.githubusercontent.com/u/8124558?v=4?s=100" width="100px;" alt="ChaelCodes"/><br /><sub><b>ChaelCodes</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=ChaelCodes" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/mdchaney"><img src="https://avatars.githubusercontent.com/u/25986?v=4?s=100" width="100px;" alt="mdchaney"/><br /><sub><b>mdchaney</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=mdchaney" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/JoshDevHub"><img src="https://avatars.githubusercontent.com/u/88392688?v=4?s=100" width="100px;" alt="JoshDevHub"/><br /><sub><b>JoshDevHub</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=JoshDevHub" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/derricklannaman"><img src="https://avatars.githubusercontent.com/u/615262?v=4?s=100" width="100px;" alt="derricklannaman"/><br /><sub><b>derricklannaman</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=derricklannaman" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/aisayo"><img src="https://avatars.githubusercontent.com/u/30131907?v=4?s=100" width="100px;" alt="aisayo"/><br /><sub><b>aisayo</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=aisayo" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/iraline"><img src="https://avatars.githubusercontent.com/u/22120173?v=4?s=100" width="100px;" alt="iraline"/><br /><sub><b>iraline</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=iraline" title="Code">💻</a></td>
    </tr>
    <tr>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/ludamillion"><img src="https://avatars.githubusercontent.com/u/1638226?v=4?s=100" width="100px;" alt="ludamillion"/><br /><sub><b>ludamillion</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=ludamillion" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/rebecarancan"><img src="https://avatars.githubusercontent.com/u/42655535?v=4?s=100" width="100px;" alt="rebecarancan"/><br /><sub><b>rebecarancan</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=rebecarancan" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/valeriecodes"><img src="https://avatars.githubusercontent.com/u/5439589?v=4?s=100" width="100px;" alt="valeriecodes"/><br /><sub><b>valeriecodes</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=valeriecodes" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/Iverick"><img src="https://avatars.githubusercontent.com/u/29335101?v=4?s=100" width="100px;" alt="Iverick"/><br /><sub><b>Iverick</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=Iverick" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/gabrielbaldao"><img src="https://avatars.githubusercontent.com/u/20587352?v=4?s=100" width="100px;" alt="gabrielbaldao"/><br /><sub><b>gabrielbaldao</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=gabrielbaldao" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/CovenantHuman"><img src="https://avatars.githubusercontent.com/u/7007647?v=4?s=100" width="100px;" alt="CovenantHuman"/><br /><sub><b>CovenantHuman</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=CovenantHuman" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/brodyf42"><img src="https://avatars.githubusercontent.com/u/32661013?v=4?s=100" width="100px;" alt="brodyf42"/><br /><sub><b>brodyf42</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=brodyf42" title="Code">💻</a></td>
    </tr>
    <tr>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/eclectic-coding"><img src="https://avatars.githubusercontent.com/u/13651291?v=4?s=100" width="100px;" alt="eclectic-coding"/><br /><sub><b>eclectic-coding</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=eclectic-coding" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/sstacey"><img src="https://avatars.githubusercontent.com/u/5226390?v=4?s=100" width="100px;" alt="sstacey"/><br /><sub><b>sstacey</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=sstacey" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/cassianoblonski"><img src="https://avatars.githubusercontent.com/u/9721558?v=4?s=100" width="100px;" alt="cassianoblonski"/><br /><sub><b>cassianoblonski</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=cassianoblonski" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/datadaveshin"><img src="https://avatars.githubusercontent.com/u/14435667?v=4?s=100" width="100px;" alt="datadaveshin"/><br /><sub><b>datadaveshin</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=datadaveshin" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/edwja"><img src="https://avatars.githubusercontent.com/u/3819249?v=4?s=100" width="100px;" alt="edwja"/><br /><sub><b>edwja</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=edwja" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/isaacm"><img src="https://avatars.githubusercontent.com/u/838526?v=4?s=100" width="100px;" alt="isaacm"/><br /><sub><b>isaacm</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=isaacm" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/khiga8"><img src="https://avatars.githubusercontent.com/u/16447748?v=4?s=100" width="100px;" alt="khiga8"/><br /><sub><b>khiga8</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=khiga8" title="Code">💻</a></td>
    </tr>
    <tr>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/amuta"><img src="https://avatars.githubusercontent.com/u/7306481?v=4?s=100" width="100px;" alt="amuta"/><br /><sub><b>amuta</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=amuta" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/RomanTurner"><img src="https://avatars.githubusercontent.com/u/74572905?v=4?s=100" width="100px;" alt="RomanTurner"/><br /><sub><b>RomanTurner</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=RomanTurner" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/chahmedejaz"><img src="https://avatars.githubusercontent.com/u/59338032?v=4?s=100" width="100px;" alt="chahmedejaz"/><br /><sub><b>chahmedejaz</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=chahmedejaz" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/tiff-o"><img src="https://avatars.githubusercontent.com/u/67130477?v=4?s=100" width="100px;" alt="tiff-o"/><br /><sub><b>tiff-o</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=tiff-o" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/stephenandersondev"><img src="https://avatars.githubusercontent.com/u/65314061?v=4?s=100" width="100px;" alt="stephenandersondev"/><br /><sub><b>stephenandersondev</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=stephenandersondev" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/yosefbennywidyo"><img src="https://avatars.githubusercontent.com/u/17536001?v=4?s=100" width="100px;" alt="yosefbennywidyo"/><br /><sub><b>yosefbennywidyo</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=yosefbennywidyo" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/steph-hickman9"><img src="https://avatars.githubusercontent.com/u/22206525?v=4?s=100" width="100px;" alt="steph-hickman9"/><br /><sub><b>steph-hickman9</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=steph-hickman9" title="Code">💻</a></td>
    </tr>
    <tr>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/notapatch"><img src="https://avatars.githubusercontent.com/u/1710795?v=4?s=100" width="100px;" alt="notapatch"/><br /><sub><b>notapatch</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=notapatch" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/jorgedjr21"><img src="https://avatars.githubusercontent.com/u/4561599?v=4?s=100" width="100px;" alt="jorgedjr21"/><br /><sub><b>jorgedjr21</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=jorgedjr21" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/costajohnt"><img src="https://avatars.githubusercontent.com/u/14304404?v=4?s=100" width="100px;" alt="costajohnt"/><br /><sub><b>costajohnt</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=costajohnt" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/Budmin"><img src="https://avatars.githubusercontent.com/u/22670558?v=4?s=100" width="100px;" alt="Budmin"/><br /><sub><b>Budmin</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=Budmin" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/CraigTreptow"><img src="https://avatars.githubusercontent.com/u/43712137?v=4?s=100" width="100px;" alt="CraigTreptow"/><br /><sub><b>CraigTreptow</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=CraigTreptow" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/arzezak"><img src="https://avatars.githubusercontent.com/u/11340522?v=4?s=100" width="100px;" alt="arzezak"/><br /><sub><b>arzezak</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=arzezak" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/tacoda"><img src="https://avatars.githubusercontent.com/u/39019266?v=4?s=100" width="100px;" alt="tacoda"/><br /><sub><b>tacoda</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=tacoda" title="Code">💻</a></td>
    </tr>
    <tr>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/zeeshan-haidar"><img src="https://avatars.githubusercontent.com/u/82927963?v=4?s=100" width="100px;" alt="zeeshan-haidar"/><br /><sub><b>zeeshan-haidar</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=zeeshan-haidar" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/aubzie305"><img src="https://avatars.githubusercontent.com/u/67928223?v=4?s=100" width="100px;" alt="aubzie305"/><br /><sub><b>aubzie305</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=aubzie305" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/big-meel"><img src="https://avatars.githubusercontent.com/u/51832012?v=4?s=100" width="100px;" alt="big-meel"/><br /><sub><b>big-meel</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=big-meel" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/hroulston"><img src="https://avatars.githubusercontent.com/u/85851116?v=4?s=100" width="100px;" alt="hroulston"/><br /><sub><b>hroulston</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=hroulston" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/dhhuynh2"><img src="https://avatars.githubusercontent.com/u/10185546?v=4?s=100" width="100px;" alt="dhhuynh2"/><br /><sub><b>dhhuynh2</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=dhhuynh2" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/GuillermoCoding"><img src="https://avatars.githubusercontent.com/u/18248767?v=4?s=100" width="100px;" alt="GuillermoCoding"/><br /><sub><b>GuillermoCoding</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=GuillermoCoding" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/HeitorMC"><img src="https://avatars.githubusercontent.com/u/34009891?v=4?s=100" width="100px;" alt="HeitorMC"/><br /><sub><b>HeitorMC</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=HeitorMC" title="Code">💻</a></td>
    </tr>
    <tr>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/FranConcaro"><img src="https://avatars.githubusercontent.com/u/61604561?v=4?s=100" width="100px;" alt="FranConcaro"/><br /><sub><b>FranConcaro</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=FranConcaro" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/colefortner"><img src="https://avatars.githubusercontent.com/u/20844376?v=4?s=100" width="100px;" alt="colefortner"/><br /><sub><b>colefortner</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=colefortner" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/JustinTan-1"><img src="https://avatars.githubusercontent.com/u/107005611?v=4?s=100" width="100px;" alt="JustinTan-1"/><br /><sub><b>JustinTan-1</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=JustinTan-1" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/leesharma"><img src="https://avatars.githubusercontent.com/u/814638?v=4?s=100" width="100px;" alt="leesharma"/><br /><sub><b>leesharma</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=leesharma" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/leilaevans"><img src="https://avatars.githubusercontent.com/u/48444125?v=4?s=100" width="100px;" alt="leilaevans"/><br /><sub><b>leilaevans</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=leilaevans" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/maebeale"><img src="https://avatars.githubusercontent.com/u/7607813?v=4?s=100" width="100px;" alt="maebeale"/><br /><sub><b>maebeale</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=maebeale" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/marcelkooi"><img src="https://avatars.githubusercontent.com/u/13142719?v=4?s=100" width="100px;" alt="marcelkooi"/><br /><sub><b>marcelkooi</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=marcelkooi" title="Code">💻</a></td>
    </tr>
    <tr>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/steve-meyers"><img src="https://avatars.githubusercontent.com/u/57697706?v=4?s=100" width="100px;" alt="steve-meyers"/><br /><sub><b>steve-meyers</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=steve-meyers" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/solebared"><img src="https://avatars.githubusercontent.com/u/8330?v=4?s=100" width="100px;" alt="solebared"/><br /><sub><b>solebared</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=solebared" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/Natblow"><img src="https://avatars.githubusercontent.com/u/85266997?v=4?s=100" width="100px;" alt="Natblow"/><br /><sub><b>Natblow</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=Natblow" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/bacchist"><img src="https://avatars.githubusercontent.com/u/1015716?v=4?s=100" width="100px;" alt="bacchist"/><br /><sub><b>bacchist</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=bacchist" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/talya19"><img src="https://avatars.githubusercontent.com/u/54947327?v=4?s=100" width="100px;" alt="talya19"/><br /><sub><b>talya19</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=talya19" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/kanishk333gupta"><img src="https://avatars.githubusercontent.com/u/81621992?v=4?s=100" width="100px;" alt="kanishk333gupta"/><br /><sub><b>kanishk333gupta</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=kanishk333gupta" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/alexmalik"><img src="https://avatars.githubusercontent.com/u/10272865?v=4?s=100" width="100px;" alt="alexmalik"/><br /><sub><b>alexmalik</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=alexmalik" title="Code">💻</a></td>
    </tr>
    <tr>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/ATMartin"><img src="https://avatars.githubusercontent.com/u/4934682?v=4?s=100" width="100px;" alt="ATMartin"/><br /><sub><b>ATMartin</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=ATMartin" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/raychiranjib1"><img src="https://avatars.githubusercontent.com/u/1073277?v=4?s=100" width="100px;" alt="raychiranjib1"/><br /><sub><b>raychiranjib1</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=raychiranjib1" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/muydanny"><img src="https://avatars.githubusercontent.com/u/57972448?v=4?s=100" width="100px;" alt="muydanny"/><br /><sub><b>muydanny</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=muydanny" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/dvsconcept1986"><img src="https://avatars.githubusercontent.com/u/2371587?v=4?s=100" width="100px;" alt="dvsconcept1986"/><br /><sub><b>dvsconcept1986</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=dvsconcept1986" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/gskifstad"><img src="https://avatars.githubusercontent.com/u/18665669?v=4?s=100" width="100px;" alt="gskifstad"/><br /><sub><b>gskifstad</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=gskifstad" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/gregblake"><img src="https://avatars.githubusercontent.com/u/1179668?v=4?s=100" width="100px;" alt="gregblake"/><br /><sub><b>gregblake</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=gregblake" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/jamesh38"><img src="https://avatars.githubusercontent.com/u/3597266?v=4?s=100" width="100px;" alt="jamesh38"/><br /><sub><b>jamesh38</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=jamesh38" title="Code">💻</a></td>
    </tr>
    <tr>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/thejwuscript"><img src="https://avatars.githubusercontent.com/u/88938117?v=4?s=100" width="100px;" alt="thejwuscript"/><br /><sub><b>thejwuscript</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=thejwuscript" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/s-espinosa"><img src="https://avatars.githubusercontent.com/u/10855116?v=4?s=100" width="100px;" alt="s-espinosa"/><br /><sub><b>s-espinosa</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=s-espinosa" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/marcoroth"><img src="https://avatars.githubusercontent.com/u/6411752?v=4?s=100" width="100px;" alt="marcoroth"/><br /><sub><b>marcoroth</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=marcoroth" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/yagosansz"><img src="https://avatars.githubusercontent.com/u/24740101?v=4?s=100" width="100px;" alt="yagosansz"/><br /><sub><b>yagosansz</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=yagosansz" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/frankljin"><img src="https://avatars.githubusercontent.com/u/52306663?v=4?s=100" width="100px;" alt="frankljin"/><br /><sub><b>frankljin</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=frankljin" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/mdr-uma"><img src="https://avatars.githubusercontent.com/u/55260223?v=4?s=100" width="100px;" alt="mdr-uma"/><br /><sub><b>mdr-uma</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=mdr-uma" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/ashstewart7"><img src="https://avatars.githubusercontent.com/u/78568904?v=4?s=100" width="100px;" alt="ashstewart7"/><br /><sub><b>ashstewart7</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=ashstewart7" title="Code">💻</a></td>
    </tr>
    <tr>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/Malinimr"><img src="https://avatars.githubusercontent.com/u/25672033?v=4?s=100" width="100px;" alt="Malinimr"/><br /><sub><b>Malinimr</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=Malinimr" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/shacon"><img src="https://avatars.githubusercontent.com/u/5545650?v=4?s=100" width="100px;" alt="shacon"/><br /><sub><b>shacon</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=shacon" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/tpham0123"><img src="https://avatars.githubusercontent.com/u/184275651?v=4?s=100" width="100px;" alt="tpham0123"/><br /><sub><b>tpham0123</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=tpham0123" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/Nwabor"><img src="https://avatars.githubusercontent.com/u/29228800?v=4?s=100" width="100px;" alt="Nwabor"/><br /><sub><b>Nwabor</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=Nwabor" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/gasperno"><img src="https://avatars.githubusercontent.com/u/7889179?v=4?s=100" width="100px;" alt="gasperno"/><br /><sub><b>gasperno</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=gasperno" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/fabioxgn"><img src="https://avatars.githubusercontent.com/u/1084729?v=4?s=100" width="100px;" alt="fabioxgn"/><br /><sub><b>fabioxgn</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=fabioxgn" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/h-m-m"><img src="https://avatars.githubusercontent.com/u/3620291?v=4?s=100" width="100px;" alt="h-m-m"/><br /><sub><b>h-m-m</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=h-m-m" title="Code">💻</a></td>
    </tr>
    <tr>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/Kerman07"><img src="https://avatars.githubusercontent.com/u/63257395?v=4?s=100" width="100px;" alt="Kerman07"/><br /><sub><b>Kerman07</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=Kerman07" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/lubc"><img src="https://avatars.githubusercontent.com/u/7442887?v=4?s=100" width="100px;" alt="lubc"/><br /><sub><b>lubc</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=lubc" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/kcdragon"><img src="https://avatars.githubusercontent.com/u/982306?v=4?s=100" width="100px;" alt="kcdragon"/><br /><sub><b>kcdragon</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=kcdragon" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/bklang"><img src="https://avatars.githubusercontent.com/u/167131?v=4?s=100" width="100px;" alt="bklang"/><br /><sub><b>bklang</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=bklang" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/BrunoViveiros"><img src="https://avatars.githubusercontent.com/u/27422266?v=4?s=100" width="100px;" alt="BrunoViveiros"/><br /><sub><b>BrunoViveiros</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=BrunoViveiros" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/gabrielcnunez"><img src="https://avatars.githubusercontent.com/u/108249540?v=4?s=100" width="100px;" alt="gabrielcnunez"/><br /><sub><b>gabrielcnunez</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=gabrielcnunez" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/Isaac-alencar"><img src="https://avatars.githubusercontent.com/u/58452911?v=4?s=100" width="100px;" alt="Isaac-alencar"/><br /><sub><b>Isaac-alencar</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=Isaac-alencar" title="Code">💻</a></td>
    </tr>
    <tr>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/JadeDickinson"><img src="https://avatars.githubusercontent.com/u/14929975?v=4?s=100" width="100px;" alt="JadeDickinson"/><br /><sub><b>JadeDickinson</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=JadeDickinson" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/jamgar"><img src="https://avatars.githubusercontent.com/u/14931684?v=4?s=100" width="100px;" alt="jamgar"/><br /><sub><b>jamgar</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=jamgar" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/Jontar-code"><img src="https://avatars.githubusercontent.com/u/51684100?v=4?s=100" width="100px;" alt="Jontar-code"/><br /><sub><b>Jontar-code</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=Jontar-code" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/jimnanney"><img src="https://avatars.githubusercontent.com/u/309995?v=4?s=100" width="100px;" alt="jimnanney"/><br /><sub><b>jimnanney</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=jimnanney" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/tmr08c"><img src="https://avatars.githubusercontent.com/u/691365?v=4?s=100" width="100px;" alt="tmr08c"/><br /><sub><b>tmr08c</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=tmr08c" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/Tscasady"><img src="https://avatars.githubusercontent.com/u/33361274?v=4?s=100" width="100px;" alt="Tscasady"/><br /><sub><b>Tscasady</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=Tscasady" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/rtkimz"><img src="https://avatars.githubusercontent.com/u/19673981?v=4?s=100" width="100px;" alt="rtkimz"/><br /><sub><b>rtkimz</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=rtkimz" title="Code">💻</a></td>
    </tr>
    <tr>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/renatamarques97"><img src="https://avatars.githubusercontent.com/u/25162312?v=4?s=100" width="100px;" alt="renatamarques97"/><br /><sub><b>renatamarques97</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=renatamarques97" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/Rockenfels"><img src="https://avatars.githubusercontent.com/u/52436369?v=4?s=100" width="100px;" alt="Rockenfels"/><br /><sub><b>Rockenfels</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=Rockenfels" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/peaonunes"><img src="https://avatars.githubusercontent.com/u/3356720?v=4?s=100" width="100px;" alt="peaonunes"/><br /><sub><b>peaonunes</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=peaonunes" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/Oli0li"><img src="https://avatars.githubusercontent.com/u/99920845?v=4?s=100" width="100px;" alt="Oli0li"/><br /><sub><b>Oli0li</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=Oli0li" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/nizam12khan"><img src="https://avatars.githubusercontent.com/u/108728893?v=4?s=100" width="100px;" alt="nizam12khan"/><br /><sub><b>nizam12khan</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=nizam12khan" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/cattywampus"><img src="https://avatars.githubusercontent.com/u/1625840?v=4?s=100" width="100px;" alt="cattywampus"/><br /><sub><b>cattywampus</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=cattywampus" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/soc-man"><img src="https://avatars.githubusercontent.com/u/56869068?v=4?s=100" width="100px;" alt="soc-man"/><br /><sub><b>soc-man</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=soc-man" title="Code">💻</a></td>
    </tr>
    <tr>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/sean-dickinson"><img src="https://avatars.githubusercontent.com/u/90267290?v=4?s=100" width="100px;" alt="sean-dickinson"/><br /><sub><b>sean-dickinson</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=sean-dickinson" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/rogesson"><img src="https://avatars.githubusercontent.com/u/5446465?v=4?s=100" width="100px;" alt="rogesson"/><br /><sub><b>rogesson</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=rogesson" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/rishijain"><img src="https://avatars.githubusercontent.com/u/946527?v=4?s=100" width="100px;" alt="rishijain"/><br /><sub><b>rishijain</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=rishijain" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/svileshina"><img src="https://avatars.githubusercontent.com/u/7723308?v=4?s=100" width="100px;" alt="svileshina"/><br /><sub><b>svileshina</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=svileshina" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/grazirs"><img src="https://avatars.githubusercontent.com/u/62312328?v=4?s=100" width="100px;" alt="grazirs"/><br /><sub><b>grazirs</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=grazirs" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/carters-code"><img src="https://avatars.githubusercontent.com/u/48076414?v=4?s=100" width="100px;" alt="carters-code"/><br /><sub><b>carters-code</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=carters-code" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/aerrin99"><img src="https://avatars.githubusercontent.com/u/102542459?v=4?s=100" width="100px;" alt="aerrin99"/><br /><sub><b>aerrin99</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=aerrin99" title="Code">💻</a></td>
    </tr>
    <tr>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/wthurston-ut"><img src="https://avatars.githubusercontent.com/u/94195990?v=4?s=100" width="100px;" alt="wthurston-ut"/><br /><sub><b>wthurston-ut</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=wthurston-ut" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/AlexWheeler"><img src="https://avatars.githubusercontent.com/u/3260042?v=4?s=100" width="100px;" alt="AlexWheeler"/><br /><sub><b>AlexWheeler</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=AlexWheeler" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/renugasaraswathy"><img src="https://avatars.githubusercontent.com/u/5791109?v=4?s=100" width="100px;" alt="renugasaraswathy"/><br /><sub><b>renugasaraswathy</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=renugasaraswathy" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/Craggar"><img src="https://avatars.githubusercontent.com/u/352775?v=4?s=100" width="100px;" alt="Craggar"/><br /><sub><b>Craggar</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=Craggar" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/AdamSajdakMck"><img src="https://avatars.githubusercontent.com/u/128195691?v=4?s=100" width="100px;" alt="AdamSajdakMck"/><br /><sub><b>AdamSajdakMck</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=AdamSajdakMck" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/zvwm"><img src="https://avatars.githubusercontent.com/u/116754727?v=4?s=100" width="100px;" alt="zvwm"/><br /><sub><b>zvwm</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=zvwm" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/farrelld09"><img src="https://avatars.githubusercontent.com/u/22310358?v=4?s=100" width="100px;" alt="farrelld09"/><br /><sub><b>farrelld09</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=farrelld09" title="Code">💻</a></td>
    </tr>
    <tr>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/jdsoteldo"><img src="https://avatars.githubusercontent.com/u/40035787?v=4?s=100" width="100px;" alt="jdsoteldo"/><br /><sub><b>jdsoteldo</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=jdsoteldo" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/allenjd3"><img src="https://avatars.githubusercontent.com/u/8092154?v=4?s=100" width="100px;" alt="allenjd3"/><br /><sub><b>allenjd3</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=allenjd3" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/Jaskaran2"><img src="https://avatars.githubusercontent.com/u/60808292?v=4?s=100" width="100px;" alt="Jaskaran2"/><br /><sub><b>Jaskaran2</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=Jaskaran2" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/JenMcD-star"><img src="https://avatars.githubusercontent.com/u/100439936?v=4?s=100" width="100px;" alt="JenMcD-star"/><br /><sub><b>JenMcD-star</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=JenMcD-star" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/JuanVqz"><img src="https://avatars.githubusercontent.com/u/7331511?v=4?s=100" width="100px;" alt="JuanVqz"/><br /><sub><b>JuanVqz</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=JuanVqz" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/katmlane"><img src="https://avatars.githubusercontent.com/u/97710598?v=4?s=100" width="100px;" alt="katmlane"/><br /><sub><b>katmlane</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=katmlane" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/mononoken"><img src="https://avatars.githubusercontent.com/u/81536479?v=4?s=100" width="100px;" alt="mononoken"/><br /><sub><b>mononoken</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=mononoken" title="Code">💻</a></td>
    </tr>
    <tr>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/Math-O5"><img src="https://avatars.githubusercontent.com/u/38463414?v=4?s=100" width="100px;" alt="Math-O5"/><br /><sub><b>Math-O5</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=Math-O5" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/moizafzal936"><img src="https://avatars.githubusercontent.com/u/51321005?v=4?s=100" width="100px;" alt="moizafzal936"/><br /><sub><b>moizafzal936</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=moizafzal936" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/rjbeers"><img src="https://avatars.githubusercontent.com/u/5741299?v=4?s=100" width="100px;" alt="rjbeers"/><br /><sub><b>rjbeers</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=rjbeers" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/rafaeelaudibert"><img src="https://avatars.githubusercontent.com/u/32079912?v=4?s=100" width="100px;" alt="rafaeelaudibert"/><br /><sub><b>rafaeelaudibert</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=rafaeelaudibert" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/jemcodes"><img src="https://avatars.githubusercontent.com/u/41805567?v=4?s=100" width="100px;" alt="jemcodes"/><br /><sub><b>jemcodes</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=jemcodes" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/bmanek"><img src="https://avatars.githubusercontent.com/u/41875460?v=4?s=100" width="100px;" alt="bmanek"/><br /><sub><b>bmanek</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=bmanek" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/zgagnon"><img src="https://avatars.githubusercontent.com/u/324922?v=4?s=100" width="100px;" alt="zgagnon"/><br /><sub><b>zgagnon</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=zgagnon" title="Code">💻</a></td>
    </tr>
    <tr>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/vishaltps"><img src="https://avatars.githubusercontent.com/u/16555538?v=4?s=100" width="100px;" alt="vishaltps"/><br /><sub><b>vishaltps</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=vishaltps" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/leevic31"><img src="https://avatars.githubusercontent.com/u/43049052?v=4?s=100" width="100px;" alt="leevic31"/><br /><sub><b>leevic31</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=leevic31" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/thiantonello"><img src="https://avatars.githubusercontent.com/u/72185566?v=4?s=100" width="100px;" alt="thiantonello"/><br /><sub><b>thiantonello</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=thiantonello" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/tjaRoxasXIII"><img src="https://avatars.githubusercontent.com/u/61096269?v=4?s=100" width="100px;" alt="tjaRoxasXIII"/><br /><sub><b>tjaRoxasXIII</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=tjaRoxasXIII" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/tanja-veljan"><img src="https://avatars.githubusercontent.com/u/108736567?v=4?s=100" width="100px;" alt="tanja-veljan"/><br /><sub><b>tanja-veljan</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=tanja-veljan" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/stufro"><img src="https://avatars.githubusercontent.com/u/6583312?v=4?s=100" width="100px;" alt="stufro"/><br /><sub><b>stufro</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=stufro" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/stephenmckeon"><img src="https://avatars.githubusercontent.com/u/63466080?v=4?s=100" width="100px;" alt="stephenmckeon"/><br /><sub><b>stephenmckeon</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=stephenmckeon" title="Code">💻</a></td>
    </tr>
    <tr>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/kazuhirodk"><img src="https://avatars.githubusercontent.com/u/7772012?v=4?s=100" width="100px;" alt="kazuhirodk"/><br /><sub><b>kazuhirodk</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=kazuhirodk" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/kinduff"><img src="https://avatars.githubusercontent.com/u/1270156?v=4?s=100" width="100px;" alt="kinduff"/><br /><sub><b>kinduff</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=kinduff" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/r-mckeith"><img src="https://avatars.githubusercontent.com/u/74464186?v=4?s=100" width="100px;" alt="r-mckeith"/><br /><sub><b>r-mckeith</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=r-mckeith" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/shuaixiaoqiang"><img src="https://avatars.githubusercontent.com/u/24687995?v=4?s=100" width="100px;" alt="shuaixiaoqiang"/><br /><sub><b>shuaixiaoqiang</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=shuaixiaoqiang" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/strangeforloop"><img src="https://avatars.githubusercontent.com/u/24727140?v=4?s=100" width="100px;" alt="strangeforloop"/><br /><sub><b>strangeforloop</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=strangeforloop" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/xcelr8"><img src="https://avatars.githubusercontent.com/u/19795313?v=4?s=100" width="100px;" alt="xcelr8"/><br /><sub><b>xcelr8</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=xcelr8" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/xeniabarreto"><img src="https://avatars.githubusercontent.com/u/88126195?v=4?s=100" width="100px;" alt="xeniabarreto"/><br /><sub><b>xeniabarreto</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=xeniabarreto" title="Code">💻</a></td>
    </tr>
    <tr>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/yyelleww70"><img src="https://avatars.githubusercontent.com/u/171301048?v=4?s=100" width="100px;" alt="yyelleww70"/><br /><sub><b>yyelleww70</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=yyelleww70" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/kasugaijin"><img src="https://avatars.githubusercontent.com/u/95949082?v=4?s=100" width="100px;" alt="kasugaijin"/><br /><sub><b>kasugaijin</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=kasugaijin" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/Naraveni"><img src="https://avatars.githubusercontent.com/u/170462097?v=4?s=100" width="100px;" alt="Naraveni"/><br /><sub><b>Naraveni</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=Naraveni" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/kyle-apex"><img src="https://avatars.githubusercontent.com/u/20145331?v=4?s=100" width="100px;" alt="kyle-apex"/><br /><sub><b>kyle-apex</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=kyle-apex" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/LeslieKornes"><img src="https://avatars.githubusercontent.com/u/25469835?v=4?s=100" width="100px;" alt="LeslieKornes"/><br /><sub><b>LeslieKornes</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=LeslieKornes" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/AlyBadawy"><img src="https://avatars.githubusercontent.com/u/1198568?v=4?s=100" width="100px;" alt="AlyBadawy"/><br /><sub><b>AlyBadawy</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=AlyBadawy" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/alexandremartins-glitch"><img src="https://avatars.githubusercontent.com/u/280412967?v=4?s=100" width="100px;" alt="alexandremartins-glitch"/><br /><sub><b>alexandremartins-glitch</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=alexandremartins-glitch" title="Code">💻</a></td>
    </tr>
    <tr>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/amycommits"><img src="https://avatars.githubusercontent.com/u/7873934?v=4?s=100" width="100px;" alt="amycommits"/><br /><sub><b>amycommits</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=amycommits" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/spotswoodb"><img src="https://avatars.githubusercontent.com/u/67289720?v=4?s=100" width="100px;" alt="spotswoodb"/><br /><sub><b>spotswoodb</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=spotswoodb" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/dcslagel"><img src="https://avatars.githubusercontent.com/u/16831228?v=4?s=100" width="100px;" alt="dcslagel"/><br /><sub><b>dcslagel</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=dcslagel" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/Daniel-Penaloza"><img src="https://avatars.githubusercontent.com/u/11881479?v=4?s=100" width="100px;" alt="Daniel-Penaloza"/><br /><sub><b>Daniel-Penaloza</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=Daniel-Penaloza" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/panacotar"><img src="https://avatars.githubusercontent.com/u/62465430?v=4?s=100" width="100px;" alt="panacotar"/><br /><sub><b>panacotar</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=panacotar" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/DianaLiao"><img src="https://avatars.githubusercontent.com/u/6047796?v=4?s=100" width="100px;" alt="DianaLiao"/><br /><sub><b>DianaLiao</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=DianaLiao" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/EduardoSCosta"><img src="https://avatars.githubusercontent.com/u/30778707?v=4?s=100" width="100px;" alt="EduardoSCosta"/><br /><sub><b>EduardoSCosta</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=EduardoSCosta" title="Code">💻</a></td>
    </tr>
    <tr>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/ElisaRmz"><img src="https://avatars.githubusercontent.com/u/25952066?v=4?s=100" width="100px;" alt="ElisaRmz"/><br /><sub><b>ElisaRmz</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=ElisaRmz" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/fisanchez"><img src="https://avatars.githubusercontent.com/u/49005233?v=4?s=100" width="100px;" alt="fisanchez"/><br /><sub><b>fisanchez</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=fisanchez" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/FionaDL"><img src="https://avatars.githubusercontent.com/u/28625558?v=4?s=100" width="100px;" alt="FionaDL"/><br /><sub><b>FionaDL</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=FionaDL" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/Gabe-Torres"><img src="https://avatars.githubusercontent.com/u/127896538?v=4?s=100" width="100px;" alt="Gabe-Torres"/><br /><sub><b>Gabe-Torres</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=Gabe-Torres" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/jonathanmeneses"><img src="https://avatars.githubusercontent.com/u/57015589?v=4?s=100" width="100px;" alt="jonathanmeneses"/><br /><sub><b>jonathanmeneses</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=jonathanmeneses" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/jyeharry"><img src="https://avatars.githubusercontent.com/u/39621946?v=4?s=100" width="100px;" alt="jyeharry"/><br /><sub><b>jyeharry</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=jyeharry" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/likevi54"><img src="https://avatars.githubusercontent.com/u/197821303?v=4?s=100" width="100px;" alt="likevi54"/><br /><sub><b>likevi54</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=likevi54" title="Code">💻</a></td>
    </tr>
    <tr>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/lautarol"><img src="https://avatars.githubusercontent.com/u/8808504?v=4?s=100" width="100px;" alt="lautarol"/><br /><sub><b>lautarol</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=lautarol" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/choznerol"><img src="https://avatars.githubusercontent.com/u/12410942?v=4?s=100" width="100px;" alt="choznerol"/><br /><sub><b>choznerol</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=choznerol" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/leslie-seeberger"><img src="https://avatars.githubusercontent.com/u/40617327?v=4?s=100" width="100px;" alt="leslie-seeberger"/><br /><sub><b>leslie-seeberger</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=leslie-seeberger" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/mateusdeap"><img src="https://avatars.githubusercontent.com/u/14188887?v=4?s=100" width="100px;" alt="mateusdeap"/><br /><sub><b>mateusdeap</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=mateusdeap" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/ncala"><img src="https://avatars.githubusercontent.com/u/53275406?v=4?s=100" width="100px;" alt="ncala"/><br /><sub><b>ncala</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=ncala" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/melvynsng"><img src="https://avatars.githubusercontent.com/u/53536373?v=4?s=100" width="100px;" alt="melvynsng"/><br /><sub><b>melvynsng</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=melvynsng" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/stephenagreer"><img src="https://avatars.githubusercontent.com/u/18668436?v=4?s=100" width="100px;" alt="stephenagreer"/><br /><sub><b>stephenagreer</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=stephenagreer" title="Code">💻</a></td>
    </tr>
    <tr>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/mattzollinhofer"><img src="https://avatars.githubusercontent.com/u/444766?v=4?s=100" width="100px;" alt="mattzollinhofer"/><br /><sub><b>mattzollinhofer</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=mattzollinhofer" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/jolenehayes"><img src="https://avatars.githubusercontent.com/u/10298376?v=4?s=100" width="100px;" alt="jolenehayes"/><br /><sub><b>jolenehayes</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=jolenehayes" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/jordano159"><img src="https://avatars.githubusercontent.com/u/22888178?v=4?s=100" width="100px;" alt="jordano159"/><br /><sub><b>jordano159</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=jordano159" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/izaguirrejoe"><img src="https://avatars.githubusercontent.com/u/14005731?v=4?s=100" width="100px;" alt="izaguirrejoe"/><br /><sub><b>izaguirrejoe</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=izaguirrejoe" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/kassandraleyba"><img src="https://avatars.githubusercontent.com/u/114712752?v=4?s=100" width="100px;" alt="kassandraleyba"/><br /><sub><b>kassandraleyba</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=kassandraleyba" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/kellyeryan"><img src="https://avatars.githubusercontent.com/u/51907753?v=4?s=100" width="100px;" alt="kellyeryan"/><br /><sub><b>kellyeryan</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=kellyeryan" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/JoelLau"><img src="https://avatars.githubusercontent.com/u/29514264?v=4?s=100" width="100px;" alt="JoelLau"/><br /><sub><b>JoelLau</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=JoelLau" title="Code">💻</a></td>
    </tr>
    <tr>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/ec1971"><img src="https://avatars.githubusercontent.com/u/27233553?v=4?s=100" width="100px;" alt="ec1971"/><br /><sub><b>ec1971</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=ec1971" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/jasperfurniss"><img src="https://avatars.githubusercontent.com/u/9158723?v=4?s=100" width="100px;" alt="jasperfurniss"/><br /><sub><b>jasperfurniss</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=jasperfurniss" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/jasonodoom"><img src="https://avatars.githubusercontent.com/u/6789916?v=4?s=100" width="100px;" alt="jasonodoom"/><br /><sub><b>jasonodoom</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=jasonodoom" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/shkm"><img src="https://avatars.githubusercontent.com/u/22677?v=4?s=100" width="100px;" alt="shkm"/><br /><sub><b>shkm</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=shkm" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/96RadhikaJadhav"><img src="https://avatars.githubusercontent.com/u/56536997?v=4?s=100" width="100px;" alt="96RadhikaJadhav"/><br /><sub><b>96RadhikaJadhav</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=96RadhikaJadhav" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/vega28"><img src="https://avatars.githubusercontent.com/u/1592789?v=4?s=100" width="100px;" alt="vega28"/><br /><sub><b>vega28</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=vega28" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/kenny-luong"><img src="https://avatars.githubusercontent.com/u/15682136?v=4?s=100" width="100px;" alt="kenny-luong"/><br /><sub><b>kenny-luong</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=kenny-luong" title="Code">💻</a></td>
    </tr>
    <tr>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/EfeAgare"><img src="https://avatars.githubusercontent.com/u/39013780?v=4?s=100" width="100px;" alt="EfeAgare"/><br /><sub><b>EfeAgare</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=EfeAgare" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/lsparlin"><img src="https://avatars.githubusercontent.com/u/1904364?v=4?s=100" width="100px;" alt="lsparlin"/><br /><sub><b>lsparlin</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=lsparlin" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/lucia-w"><img src="https://avatars.githubusercontent.com/u/6162142?v=4?s=100" width="100px;" alt="lucia-w"/><br /><sub><b>lucia-w</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=lucia-w" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/ekulz"><img src="https://avatars.githubusercontent.com/u/12506356?v=4?s=100" width="100px;" alt="ekulz"/><br /><sub><b>ekulz</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=ekulz" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/malsmr"><img src="https://avatars.githubusercontent.com/u/33208593?v=4?s=100" width="100px;" alt="malsmr"/><br /><sub><b>malsmr</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=malsmr" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/msespos"><img src="https://avatars.githubusercontent.com/u/62808851?v=4?s=100" width="100px;" alt="msespos"/><br /><sub><b>msespos</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=msespos" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/mgrigoriev8109"><img src="https://avatars.githubusercontent.com/u/43343880?v=4?s=100" width="100px;" alt="mgrigoriev8109"/><br /><sub><b>mgrigoriev8109</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=mgrigoriev8109" title="Code">💻</a></td>
    </tr>
    <tr>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/naomiyocum"><img src="https://avatars.githubusercontent.com/u/102825498?v=4?s=100" width="100px;" alt="naomiyocum"/><br /><sub><b>naomiyocum</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=naomiyocum" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/cashmann"><img src="https://avatars.githubusercontent.com/u/38586565?v=4?s=100" width="100px;" alt="cashmann"/><br /><sub><b>cashmann</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=cashmann" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/nepaakash"><img src="https://avatars.githubusercontent.com/u/42288829?v=4?s=100" width="100px;" alt="nepaakash"/><br /><sub><b>nepaakash</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=nepaakash" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/msalli"><img src="https://avatars.githubusercontent.com/u/7664271?v=4?s=100" width="100px;" alt="msalli"/><br /><sub><b>msalli</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=msalli" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/heyapricot"><img src="https://avatars.githubusercontent.com/u/14355495?v=4?s=100" width="100px;" alt="heyapricot"/><br /><sub><b>heyapricot</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=heyapricot" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/Benabik"><img src="https://avatars.githubusercontent.com/u/133455?v=4?s=100" width="100px;" alt="Benabik"/><br /><sub><b>Benabik</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=Benabik" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/apocosipadrino"><img src="https://avatars.githubusercontent.com/u/33580126?v=4?s=100" width="100px;" alt="apocosipadrino"/><br /><sub><b>apocosipadrino</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=apocosipadrino" title="Code">💻</a></td>
    </tr>
    <tr>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/invacuo"><img src="https://avatars.githubusercontent.com/u/3662050?v=4?s=100" width="100px;" alt="invacuo"/><br /><sub><b>invacuo</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=invacuo" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/uzorjchibuzor"><img src="https://avatars.githubusercontent.com/u/32690770?v=4?s=100" width="100px;" alt="uzorjchibuzor"/><br /><sub><b>uzorjchibuzor</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=uzorjchibuzor" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/cflannagan"><img src="https://avatars.githubusercontent.com/u/214966?v=4?s=100" width="100px;" alt="cflannagan"/><br /><sub><b>cflannagan</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=cflannagan" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/dalmaboros"><img src="https://avatars.githubusercontent.com/u/2686072?v=4?s=100" width="100px;" alt="dalmaboros"/><br /><sub><b>dalmaboros</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=dalmaboros" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/dmcarmo"><img src="https://avatars.githubusercontent.com/u/16320169?v=4?s=100" width="100px;" alt="dmcarmo"/><br /><sub><b>dmcarmo</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=dmcarmo" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/etagwerker"><img src="https://avatars.githubusercontent.com/u/17584?v=4?s=100" width="100px;" alt="etagwerker"/><br /><sub><b>etagwerker</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=etagwerker" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/fransan6"><img src="https://avatars.githubusercontent.com/u/114738789?v=4?s=100" width="100px;" alt="fransan6"/><br /><sub><b>fransan6</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=fransan6" title="Code">💻</a></td>
    </tr>
    <tr>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/fbuys"><img src="https://avatars.githubusercontent.com/u/3785596?v=4?s=100" width="100px;" alt="fbuys"/><br /><sub><b>fbuys</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=fbuys" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/Br0k3nh4nd012"><img src="https://avatars.githubusercontent.com/u/65460935?v=4?s=100" width="100px;" alt="Br0k3nh4nd012"/><br /><sub><b>Br0k3nh4nd012</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=Br0k3nh4nd012" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/gaurijo"><img src="https://avatars.githubusercontent.com/u/103534307?v=4?s=100" width="100px;" alt="gaurijo"/><br /><sub><b>gaurijo</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=gaurijo" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/ghousemohamed"><img src="https://avatars.githubusercontent.com/u/56545288?v=4?s=100" width="100px;" alt="ghousemohamed"/><br /><sub><b>ghousemohamed</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=ghousemohamed" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/gVirtu"><img src="https://avatars.githubusercontent.com/u/15658199?v=4?s=100" width="100px;" alt="gVirtu"/><br /><sub><b>gVirtu</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=gVirtu" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/Thekote"><img src="https://avatars.githubusercontent.com/u/45775182?v=4?s=100" width="100px;" alt="Thekote"/><br /><sub><b>Thekote</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=Thekote" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/harsha-flipp"><img src="https://avatars.githubusercontent.com/u/82414488?v=4?s=100" width="100px;" alt="harsha-flipp"/><br /><sub><b>harsha-flipp</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=harsha-flipp" title="Code">💻</a></td>
    </tr>
    <tr>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/himanshu007-creator"><img src="https://avatars.githubusercontent.com/u/65963997?v=4?s=100" width="100px;" alt="himanshu007-creator"/><br /><sub><b>himanshu007-creator</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=himanshu007-creator" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/Ivarkentje"><img src="https://avatars.githubusercontent.com/u/22929670?v=4?s=100" width="100px;" alt="Ivarkentje"/><br /><sub><b>Ivarkentje</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=Ivarkentje" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/jacobherrington"><img src="https://avatars.githubusercontent.com/u/11466782?v=4?s=100" width="100px;" alt="jacobherrington"/><br /><sub><b>jacobherrington</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=jacobherrington" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/jacoblogue"><img src="https://avatars.githubusercontent.com/u/86848183?v=4?s=100" width="100px;" alt="jacoblogue"/><br /><sub><b>jacoblogue</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=jacoblogue" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://www.linkedin.com/in/utkarsh-dixit-b34639103/"><img src="https://avatars.githubusercontent.com/u/72229040?v=4?s=100" width="100px;" alt="Utkarsh Dixit"/><br /><sub><b>Utkarsh Dixit</b></sub></a><br /><a href="https://github.com/rubyforgood/casa/commits?author=UtkarshDixit-97" title="Code">💻</a></td>
    </tr>
  </tbody>
</table>

<!-- markdownlint-restore -->
<!-- prettier-ignore-end -->

<!-- ALL-CONTRIBUTORS-LIST:END -->

This project follows the [all-contributors](https://github.com/all-contributors/all-contributors) specification. Contributions of any kind welcome!

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
