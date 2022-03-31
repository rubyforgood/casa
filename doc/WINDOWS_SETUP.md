## Assumptions

This guide assumes you have [WSL](https://docs.microsoft.com/en-us/windows/wsl/install) (Windows Subsystem for Linux) enabled. Once enabled, you can run Linux on Windows [several different ways](https://docs.microsoft.com/en-us/windows/wsl/install#ways-to-run-multiple-linux-distributions-with-wsl), but we suggest using [Windows Terminal](https://docs.microsoft.com/en-us/windows/terminal/install).

You will need the following local tools installed:

1. Ruby
2. NodeJs (optional)
3. Postgres
4. Google Chrome

### Ruby

Install Ruby and Ruby on Rails using the [tutorial at Go Rails](https://gorails.com/setup/windows/10#ruby)

1. Follow the instructions for 'Install Ruby'. 
   **Be sure to install the ruby version in `.ruby-version`. Right now that's Ruby 3.1.0**
2. If git is not already installed on your system, follow the instructions for 'Install Git'.
3. Follow the instructions for 'Install Rails'.

**Do NOT set up a database. Stop here! We'll set up Postgres in a moment.**

### NodeJS

The Casa package frontend leverages several javascript packages managed through `yarn`, so if you are working on those elements you will want to have node, npm, and yarn installed.

1. (Recommended) [Install nvm](https://github.com/nvm-sh/nvm#installing-and-updating), which is a node version manager.
2. Install a current LTS version of Node. lts/fermium works.
3. [Install yarn](https://classic.yarnpkg.com/en/docs/install). Make sure you install it from the official Yarn repo instead of cmdtest.

### Postgres

1. [Install PostgresSQL](https://docs.microsoft.com/en-us/windows/wsl/tutorials/wsl-database#install-postgresql) for WSL
2. You may need to create a postgres user that matches your Linux username and give it permission to create databases during db setup.

### Google Chrome

Many of the frontend tests are run using Google Chrome, so if you don't already have that installed you may wish to [install it](https://www.google.com/chrome/downloads/)

### Casa

Follow the [instructions](https://github.com/rubyforgood/casa#general-setup-instructions) under 'Downloading the Project', 'Installing Packages',  'Database Setup', and 'Webpacker One Time Setup'.