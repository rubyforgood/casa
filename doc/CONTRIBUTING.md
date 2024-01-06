# Contributing  
We ♥ contributors! By participating in this project, you agree to abide by the Ruby for Good [code of conduct](https://github.com/rubyforgood/code-of-conduct).

If you have any questions about an issue, comment on the issue, open a new issue or ask in [the RubyForGood slack](https://join.slack.com/t/rubyforgood/shared_invite/zt-21pyz2ab8-H6JgQfGGI0Ab6MfNOZRIQA). CASA has a `#casa` channel in the Slack. Our channel in slack also contains a zoom link for office hours every day office hours are held.

You won't be yelled at for giving your best effort. The worst that can happen is that you'll be politely asked to change something. We appreciate any sort of contributions, and don't want a wall of rules to get in the way of that.

## Contributing Steps  
### Issues  
All work is organized by issues.  
[Find issues here.](https://github.com/rubyforgood/casa/projects/1)  

If you would like to contribute, please ask for an issue to be assigned to you.  
If you would like to contribute something that is not represented by an issue, please make an issue and assign yourself.  
Only take multiple issues if they are related and you can solve all of them at the same time with the same pull request.  

### Pull Requests  
If you are so inclined, you can open a draft PR as you continue to work on it.

1. Follow [the setup guide](https://github.com/rubyforgood/casa#installation) to get the project working locally.

1. We only accept pull requests with passing tests, and it's great to know that you have a clean slate. To run the tests use `bundle exec rspec`

1. Add a test for your change. If you are adding functionality or fixing a  bug, you should add a test!

1. Run linters and fix any linting errors that come up.  
   - (from the repo root) `./bin/git_hooks/lint`

1. Push to your branch/fork and submit a pull request. Include the issue number (ex. `Resolves #1`) in the PR description. This will ensure the issue gets closed automatically when the pull request gets merged.

#### Pull Request Checks
There are scripts that check the code to ensure the code is working. Most of them need to pass. You can see the scripts run at the bottom of your pull request webpage. More about the scripts [here](https://github.com/rubyforgood/casa/wiki/Pull-Request-Checks). Pull requests are also manually reviewed. We may request changes after a manual review. We will try to respond to your PR quickly.  

Some qualities of good pull requests:  
* Small line diff count. Several small pull requests for a large issue are preferred over one big pull request.  
* Include tests that fail without your code, and pass with it.
* For pull requests changing UI, make sure the UI matches the rest of the site. Some of our users aren't great with computers and we don't want to make them learn new things if we don't need to.  
* Update the documentation, for things like new rails/bash commands. Please include a guide if modifying the code in the future is difficult. For example [editing .docx templates](https://github.com/rubyforgood/casa/wiki/How-to-edit-docx-templates---word-document-court-report) is difficult because the documentation is hard to find and it requires microsoft word.  
* If your pull request involves user permissions, use [policy files](https://github.com/varvet/pundit#policies).  
* If your pull request has an erb file with complex rails logic inside of it, please use a [decorator](https://medium.com/@kosovacsedad/ruby-on-rails-decorator-design-pattern-b54a1afd03c8).  
