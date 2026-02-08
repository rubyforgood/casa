---
name: Race Conditon Epic Child Issue
about: Issue describing system tests that haven't been checked yet for the race condition
title: "Race Condition Check: "
labels: ["Type: Bug", "Help Wanted"]
---

Our system tests run on a mock browser. Sometimes Github's servers are strained so the browser performs very slowly. For some tests this causes a race condition between entering data using a the browser and checking the result of entering data directly from the database. The database check happens before the browser actions are completed if the browser's performance is crippled enough.

Examples:
#### Good `expect`s
```ruby
  expect(page).to have_content "Court Date"
  expect(page).to have_text(supervisor_name)
  
  wait_for_download
  expect(download_docx.paragraphs.map(&:to_s)).to include("Hearing Date: January 8, 2021")
```

#### Bad/Suspicious `expect`s
```ruby
  expect(CourtDate.count).to eq 2
  expect(supervisor.reload).not_to be_active
  
  deliveries = ActionMailer::Base.deliveries
  expect(deliveries.count).to eq(1)
  expect(deliveries.last.subject).to have_text "CASA Console invitation instructions"
```

The bad `expect`s don't get their data from the browser. If they don't get the data from the browser, it doesn't make them automatically invalid. If the test waits for the page to load before checking data from the backend, that's valid. However for a system test, we should try to write them so all the steps of the test would have meaning to a user. A user would be able to see elements on a webpage but they wouldn't be able to check the database.
