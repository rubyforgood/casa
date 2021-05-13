## Contributing

We ♥ contributors! By participating in this project, you agree to abide by the Ruby for Good [code of conduct].

If you're unsure about an issue or have any questions or concerns, just ask in an *existing issue* or *open a new issue*. If you would like to talk to other contributors and get more context about the project before jumping in, you can request to join [RubyForGood Slack](https://rubyforgood.herokuapp.com/). Once you are in Slack, come by `#casa` channel, introducce yourself and ask us questions!

If you don't have any questions, the issue is clear, and no one has commented saying they are working on the isssue, you can work on it! If you are so inclined, you can open a draft PR as you continue to work on it. You won't be yelled at for giving your best effort. The worst that can happen is that you'll be politely asked to change something. We appreciate any sort of contributions, and don't want a wall of rules to get in the way of that.

Here are the basic steps to submit a pull request.

1. Claim an issue on [our issue tracker][issues] by commenting on the issue saying you are working on it. If the issue doesn't exist yet, open it. Please only claim one at a time.

1. Fork the [repo] and clone your forked repo locally on your machine.

1. Follow [setup guidelines][setup] to get the project setup locally.

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
## to run cypress tests
bundle exec rails s -p 4040
npm run test:cypress
```

If you are wondering how to keep your fork in sync with the main [repo], follow this [github guide](https://help.github.com/en/github/collaborating-with-issues-and-pull-requests/syncing-a-fork).

[code of conduct]: https://github.com/rubyforgood/code-of-conduct
[issues]: https://github.com/rubyforgood/casa/issues?q=is%3Aopen+is%3Aissue+label%3A%22Status%3A+Available%22
[repo]: https://github.com/rubyforgood/casa
[setup]: https://github.com/rubyforgood/casa#developing-
