---
name: Flaky Test
about: one of the tests is inconsistent and likely producing false positives
title: "Bug: Flaky Test"
labels: ["Type: Bug", "Help Wanted"]
---
Flaky tests are defined as tests that return both passes and failures despite no changes to the code or the test itself
Fix the test so it runs consistently.

### Environment
ex: docker

### Sample Error Output:
```
```

### How to Replicate
Try running the test lots of times locally
`bundle exec rspec spec/...`

### Questions? Join Slack!

We highly recommend that you join us in slack https://rubyforgood.herokuapp.com/ #casa channel to ask questions quickly and hear about office hours (currently Tuesday 5-7pm Pacific), stakeholder news, and upcoming new issues.
