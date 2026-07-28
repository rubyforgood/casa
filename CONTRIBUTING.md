# Contributing to CASA

Thank you for helping CASA and Ruby for Good. CASA is a Ruby on Rails
application that helps Court Appointed Special Advocate organizations support
volunteers, supervisors, and administrators.

By participating in this project, you agree to follow the Ruby for Good
[code of conduct](https://github.com/rubyforgood/code-of-conduct).

## Where to ask questions

Use the channel that keeps your question closest to the work:

- Ask issue-specific questions in the GitHub issue.
- Ask pull request questions in the pull request thread.
- Join the Ruby for Good [Slack](https://join.slack.com/t/rubyforgood/shared_invite/zt-35218k86r-vlIiWqig54c9t~_LkGpQ7Q)
  and use the `#casa` channel for fast help.
- Join the CASA [Discord](https://discord.gg/qJcw2RZH8Q) for office hours and
  project discussion.
- Check the CASA [Google Calendar](https://bit.ly/casacal) for office hours and
  stakeholder meetings.

Maintainers usually check issues and pull requests every day or three. If you
have been blocked for a few days, leave a concise GitHub comment or ask in
`#casa`.

## Getting set up

The [README](README.md) is the main setup guide. Start there for the current
Ruby, Node.js, PostgreSQL, seed user, and local server instructions.

Fast setup options:

- Use [GitHub Codespaces](https://codespaces.new/rubyforgood/casa/tree/main?quickstart=1)
  if you want a browser-based environment.
- Follow the README [local setup instructions](README.md#local-setup-instructions)
  if you want to run CASA on your machine.
- Use the [Docker setup guide](doc/DOCKER.md) if you prefer containers.

Platform-specific notes:

- [Linux setup](doc/LINUX_SETUP.md)
- [macOS setup](doc/MAC_SETUP.md)
- [Nix setup](doc/NIX_SETUP.md)
- [Windows Subsystem for Linux setup](doc/WSL_SETUP.md)

After setup, verify the app with:

```sh
bin/setup
bin/dev
```

Then open <http://localhost:3000/> and log in with one of the README
[seed users](README.md#logging-in-with-seed-users).

When you pull fresh changes from `main`, run:

```sh
bin/update
```

## Finding something to work on

Good starting places:

- [Good First Issue](https://github.com/rubyforgood/casa/labels/Good%20First%20Issue)
  issues are intended for new contributors.
- [Help Wanted](https://github.com/rubyforgood/casa/labels/Help%20Wanted)
  issues are open to community contributors.
- [Unassigned open issues](https://github.com/rubyforgood/casa/issues?q=is%3Aissue%20is%3Aopen%20no%3Aassignee)
  are available if no recent comment says someone is already working on them.

Before starting:

1. Read the issue and recent comments.
2. Make sure the issue is not assigned.
3. Comment that you would like to work on it and ask to be assigned.
4. Wait for a maintainer if the issue needs clarification.

Only take multiple issues when they are closely related and can be solved in the
same pull request. If you want to work on something that does not have an issue,
open an issue first so maintainers can confirm the direction.

If you cannot continue an assigned issue, comment on the issue so someone else
can pick it up. The repository warns contributors after 10 days of inactivity and
may unassign inactive issues after 15 days.

## Development workflow

Fork the repository unless a maintainer has given you direct commit access.

Add the upstream remote once:

```sh
git remote add upstream https://github.com/rubyforgood/casa.git
```

Start each issue from an updated `main` branch:

```sh
git checkout main
git pull upstream main
git checkout -b 6910-contributing-guide
```

Use a short, descriptive branch name. Including the issue number helps reviewers,
for example `6910-contributing-guide` or `5979-learning-hours-report`.

Keep the change focused on the issue. Small pull requests are easier to review
and merge than broad rewrites.

## Tests and linters

Run the smallest useful test command while developing, then run the broader
checks before opening a ready pull request.

Common test commands:

```sh
bundle exec rspec
npm run test
```

Targeted examples:

```sh
bundle exec rspec spec/models/user_spec.rb
bundle exec rspec spec/requests/case_contacts_spec.rb
npm run test -- app/javascript/__tests__/validated_form.test.js
```

Common lint commands:

```sh
bundle exec standardrb
bundle exec erb_lint --lint-all
npm run lint
```

To run the repository's fixer commands:

```sh
bin/lint
```

To lint only files staged or changed on your branch:

```sh
./bin/git_hooks/lint --staged
./bin/git_hooks/lint --unpushed
```

For documentation-only pull requests, there may not be a useful automated test.
In that case, validate links and formatting, then explain that in the pull
request's testing section.

## Testing expectations

Add or update tests for behavior changes. A good pull request includes a test
that would fail without the change and pass with it.

Use the test type that matches the behavior:

- Model specs for validations, associations, scopes, and model-level business
  rules.
- Request specs for routes, controller behavior, permissions, and responses.
- System specs for user-visible workflows, JavaScript-driven UI, and role-based
  behavior.
- View or component specs for rendering changes that do not need a full browser
  flow.
- Policy specs for authorization changes.
- Service, job, mailer, and importer specs for the matching application object.
- Jest tests for JavaScript in `app/javascript`.

For UI changes, run the app locally and include screenshots in the pull request.
If a change affects permissions, test at least one allowed role and one denied
role.

## Pull request conventions

Open a draft pull request when you want early feedback. Mark it ready for review
when the code, tests, and description are ready. If maintainers are using labels,
use or ask for `🚧 Status: WIP` while the pull request is not ready and `Ready`
when it is ready.

Use a short, action-oriented pull request title. Including the issue number is
helpful when the title would otherwise be ambiguous, for example:

```text
6910 - Flesh out contributor guide
```

Fill out the pull request template:

- Link the issue with `Resolves #1234` when the pull request should close it.
- Explain what changed and why.
- List the exact tests and linters you ran.
- Include screenshots for UI changes.
- Note any follow-up work that should become a separate issue.

Before requesting review:

1. Rebase or merge the latest `main` if your branch is stale.
2. Run the relevant tests and linters.
3. Review your own diff for unrelated files, debugging output, and missing docs.
4. Push your branch and open the pull request from your fork.

## Code review

Automated checks run at the bottom of the pull request. Most of them need to pass
before merge. If a CI failure looks flaky, post the failed build link in
`#casa`.

Maintainers may ask for changes. Respond in the pull request thread, push
follow-up commits to the same branch, and re-request review when ready.
Maintainers decide when a pull request is ready to merge.

## Documentation

Update documentation when you add setup steps, commands, workflows, permissions,
background jobs, user-facing behavior, or anything else that future contributors
will need to understand. The [README](README.md), `doc/` directory, and
[wiki](https://github.com/rubyforgood/casa/wiki) are the main documentation
surfaces.
