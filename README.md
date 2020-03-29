# README

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version

* System dependencies

* Configuration

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

### Setup to develop:

1. install a ruby version manager: [rvm](https://rvm.io/) or [rbenv](https://github.com/rbenv/rbenv)
1. when you cd into the project diretory, let your version manager install the ruby versionin .ruby-version
1. gem install bundler
1. bundle install

#### One-time already-done project setup (for historical reference)

1. install a ruby version manager: rvm or rbenv
1. rvm install ruby 2.7.0 # should be auto-installed when you cd into the casa directory because of .ruby-version
1. gem install bundler
1. bundle install
1. rails new . -d postgresql --webpacker react
1. [brew install postgres](https://wiki.postgresql.org/wiki/Homebrew) OR brew postgresql-upgrade-database (if you have an older version of postgres)
1. rails db:create # requires running local postgres
1. rails generate scaffold Case case_number:string teen_program_eligible:boolean
1. rake db:migrate
1. brew install yarm OR https://yarnpkg.com/lang/en/docs/install/
1. rails webpacker:install
1. rails server




TODO:

missing react????

Add CI?

rails generate devise:install
rails generate devise user
rails db:migrate
rails generate devise:views


casa: name
all_casa_admin: email, name, hashed_password(devise)
user: email, name, casa_id, hashed_password(devise), role(enum: inactive, volunteer, supervisor, casa-admin)
supervisor_volunteer: volunteer_user_id, supervisor_user_id
supervisor_case: supervisor_user_id, case_id
case_assignment: volunteer_user_id, case_id, is_active - since multiple volunteers can be assigned to the same case in different quarters
case: case#, teen_program_eligible
case_update: user_id, case_id, (since a volunteer can switch cases or have multiple), update_type. (youth, school, social worker, therapeutic agency worker contact, therapist, attorney, bio-parent, foster parent, other family contact, supervisor, court, other), other_type_text
uploaded_import: import_json (only saved fields?) maybe don't do this at all, in-memory only

