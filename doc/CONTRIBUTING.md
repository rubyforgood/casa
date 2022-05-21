# Contributing
WIP Under construction sorry for the temporary incoherence.

We ♥ contributors! By participating in this project, you agree to abide by the Ruby for Good [code of conduct].

If you have any questions about an issue, comment on the issue, open a new issue or ask in [the RubyForGood slack](https://rubyforgood.herokuapp.com/). CASA has a `#casa` channel in the Slack. Our channel in slack also contains a zoom link for office hours every day office hours are held.  
  
You won't be yelled at for giving your best effort. The worst that can happen is that you'll be politely asked to change something. We appreciate any sort of contributions, and don't want a wall of rules to get in the way of that.

## Contributing Procedure  
### Issues  
All work is organized by issues.  
[Find issues here.][issues]  
If you would like to contribute, please ask for an issue to be assigned to you.  
If you would like to contribute something that is not represented by an issue, please make an issue and assign yourself.  
Only take multiple issues if they are related and you can solve all of them at the same time with the same pull request.  

### Pull Requests  
If you are so inclined, you can open a draft PR as you continue to work on it.

1. Fork the [repo] and clone your forked repo locally on your machine.

1. Follow [setup guidelines](https://github.com/rubyforgood/casa#installation) to get the project setup locally.

1. Run the tests. We only take pull requests with passing tests, and it's great to know that you have a clean slate: `bundle exec rake`

1. Add a test for your change. If you are adding functionality or fixing a  bug, you should add a test!

1. Make the test pass.

1. Run linters and fix any linting errors they brings up.
   1. `bundle exec standardrb --fix` is required by CI
   1. But you should also be a good citizen and run:
      1. `bundle exec erblint --lint-all --autocorrect`
      1. `yarn lint:fix`

1. Push to your fork and submit a pull request. Include the issue number (ex. `Resolves #1`) in the PR description.

1. For any changes, please create a feature branch and open a PR for it when you feel it's ready to merge. Even if there's no real disagreement about a PR, at least one other person on the team needs to look over a PR before merging. The purpose of this review requirement is to ensure shared knowledge of the app and its changes and to take advantage of the benefits of working together changes without any single person being a bottleneck to making progress.

At this point you're waiting on us–we'll try to respond to your PR quickly. We may suggest some changes or improvements or alternatives.

Some things that will increase the chance that your pull request is accepted:

* Use Rails idioms and helpers
* Include tests that fail without your code, and pass with it
* Update the documentation, the surrounding one, examples elsewhere, guides, whatever is affected by your contribution
* Ensure that the following all pass locally:
```
bundle exec brakeman
bundle exec standardrb
bundle exec rake
```

If you are wondering how to keep your fork in sync with the main [repo], follow this [github guide](https://help.github.com/en/github/collaborating-with-issues-and-pull-requests/syncing-a-fork).

[code of conduct]: https://github.com/rubyforgood/code-of-conduct
[issues]: https://github.com/rubyforgood/casa/issues?q=is%3Aopen+is%3Aissue+label%3A%22Status%3A+Available%22
[repo]: https://github.com/rubyforgood/casa
[setup]: https://github.com/rubyforgood/casa#developing-
