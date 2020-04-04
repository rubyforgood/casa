# CASA Project & Organization Overview
[![Maintainability](https://api.codeclimate.com/v1/badges/???/maintainability)](https://codeclimate.com/github/rubyforgood/casa/maintainability)
[![Test Coverage](https://api.codeclimate.com/v1/badges/???/test_coverage)](https://codeclimate.com/github/rubyforgood/casa/test_coverage)
[![Build Status](https://travis-ci.org/rubyforgood/casa.svg?branch=master)](https://travis-ci.org/rubyforgood/casa) 
[![View performance data on Skylight](https://badges.skylight.io/status/tFh7xrs3Qnaf.svg?token=1C-Q7p8jEFlG7t69Yl5DaJwa-ipWI8gLw9wLJf53xmQ)](https://www.skylight.io/app/applications/tFh7xrs3Qnaf)
[![Known Vulnerabilities](https://snyk.io/test/github/rubyforgood/casa/badge.svg)](https://snyk.io/test/github/rubyforgood/casa)

CASA (Court Appointed Special Advocate) is a role fulfilled by a trained volunteer sworn into a county-level juvenile dependency court system to advocate on behalf of a youth in the corresponding county's foster care system. CASA is also the namesake role of the national organization, CASA, which exists to cultivate and supervise volunteers carrying out this work – with county level chapters (operating relatively independently of each other) across the country. 

<strong>PG CASA (Prince George's County CASA in Maryland) seeks a volunteer management system to:</strong>
- provide volunteers with a portal for logging activity
- oversee volunteer activity 
- generate reports on volunteer activity

<strong>How CASA works:</strong>
- Foster Youth (or case worker associated with Foster Youth) requests a CASA Volunteer.
- CASA chapter pairs Youth with Volunteer.
- Volunteer spends significant time getting to know and supporting the youth, including at court appearances. 
- Case Supervisor oversees CASA Volunteer paired with Foster Youth and monitors, tracks, and advises on all related activities.
- At PG CASA, the minimum volunteer commitment is one year (this varies by CASA chapter, in San Francisco the minimum commitment is ~ two years). Many CASA volunteers remain in a Youth's life well beyond their youth. The lifecycle of a volunteer is very long, so there's a lot of activity for chapters to track!

<strong>Why?</strong>
Many adults circulate in and out of a Foster Youth's life, but very few of them (if any) remain. CASA volunteers are by design, unpaid, unbiased, and consistent adult figures for Foster Youth who are not bound to support them by fiscal or legal requirements. 

<strong>Project Terminology</strong>
- Foster Youth = _CasaCase_
- CASA Volunteer = _Volunteer_
- Case Supervisor = _Case Supervisor_
- CASA Administrator = _Superadmin_

<strong>Project Considerations</strong>
- PG CASA is operating under a very tight budget. They currently _manually input volunteer data_ into <a href="http://www.simplyoptima.com/">a volunteer management software built specifically for CASA,</a> but upgrading their account for multiple user licenses to allow volunteers to self-log activity data is beyond their budget ($0). Hence why we are building as lightweight a solution as possible that can sustain itself on Microsoft Azure nonprofit credits for hosting (totalling $3,500 annually).
- While the scope of this platform's use is currently only for PG County CASA, we are building with a mind toward multitenancy so this platform could prospectively be used by CASA chapters across the country. We consider PG CASA an early beta tester of this platform. 

<p><strong>More information:</strong></p>
<p><a href="https://pgcasa.org/">Learn more about PG CASA here.</a></p>
<p><a href="https://pgcasa.org/volunteer-description/">You can read the complete role description of a CASA volunteer in Prince George's County here.</a></p>

### Staging Environment on Heroku

https://casa-r4g-staging.herokuapp.com/

### Setup to develop:

1. install a ruby version manager: [rvm](https://rvm.io/) or [rbenv](https://github.com/rbenv/rbenv)
1. when you cd into the project diretory, let your version manager install the ruby version in `.ruby-version`
1. `gem install bundler`
1. Make sure that postgres is installed [brew install postgres](https://wiki.postgresql.org/wiki/Homebrew) OR brew postgresql-upgrade-database (if you have an older version of postgres)
1. `bundle install`
1. `bundle exec rails db:setup`
1. `bundle exec rails spec`
1. rails db:create # requires running local postgres
1. rails db:migrate
1. `bundle exec rails server` # run server

#### Common issues

1. If your rake/rake commands hang forever instead of running, try: `rails app:update:bin #`



