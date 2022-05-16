require 'octokit' # gem install octokit
regex = /t\(["']/
GITHUB_ACCESS_TOKEN = ENV["GITHUB_ACCESS_TOKEN"]
client = Octokit::Client.new(:access_token => GITHUB_ACCESS_TOKEN)
ticket_number = ENV["START_TICKET_NUMBER"].to_i || 1
p "Starting at ticket: #{ticket_number}"
# repo_name = 'compwron/practice-ticket-creation'
repo_name = 'rubyforgood/casa'


skip = [
    "app/views/all_casa_admins/casa_admins/_form.html.erb",
    "app/views/all_casa_admins/casa_admins/edit.html.erb",
    "app/views/all_casa_admins/casa_orgs/new.html.erb",
    "app/views/all_casa_admins/casa_orgs/show.html.erb",
    "app/views/all_casa_admins/edit.html.erb",
    "app/views/all_casa_admins/new.html.erb",
    "app/views/casa_admins/_form.html.erb",
    "app/views/casa_admins/edit.html.erb",
    "app/views/casa_admins/index.html.erb",
    "app/views/casa_admins/new.html.erb",
    "app/views/casa_cases/_court_dates.html.erb",
    "app/views/casa_cases/_filter.html.erb",
    "app/views/casa_cases/_filter_my_cases.html.erb",
    "app/views/casa_cases/_form.html.erb",
    "app/views/casa_cases/_inactive_case.html.erb",
    "app/views/casa_cases/_other_duties.html.erb",
    "app/views/casa_cases/_thank_you_modal.html.erb",
    "app/views/casa_cases/_volunteer_assignment.html.erb",
    "app/views/casa_cases/edit.html.erb",
    "app/views/casa_cases/index.html.erb",
    "app/views/casa_cases/new.html.erb",
    "app/views/casa_cases/show.html.erb",
    "app/views/casa_org/_contact_type_groups.html.erb",
    "app/views/casa_org/_contact_types.html.erb",
]

Dir.glob("**/*.html.erb").each do |filename|
  if skip.include?(filename)
    p "skipping #{filename} because it's in the skip list"
    next
  end

  if File.read(filename).match? regex
    filename_parts = filename.split('/')
    title = "Railsconf #{ticket_number}: update t() in #{filename}"
    view_name = filename_parts[3]
    action_name = filename_parts[4]&.gsub('.html.erb', '')
    if action_name&.start_with?('_')
      action_name = "some_action_name"
    end
    body = %Q{Thank you for coming to our workshop!

To complete this issue:
1. open `#{filename}`
1. find each call of `t(STRING)`
1. look up `STRING` in `config/locales/views.en.yml`
    1. the YAML file is nested, first with the language (always `en` here), then the view name, then the action name
    1. so for your `STRING`, look under `en:` then `#{view_name}:` then `#{action_name}:` and then `STRING:`
    1. if you need any help figuring the view or action name to look up the translation with, please ask a workshop helper
1. replace the usage of `t(` with the translation you found in `config/locales/views.en.yml`

This will simplify our templates and make it easier to maintain the code going forward.

Example:

```
Before:
<span><%= t(".title") %></span>

In config/locales/views.en.yml:
en:
  #{view_name}:
    #{action_name}:
      title: Hello world

After:
<span>Hello world</span>
```

### Questions? Join Slack!

We highly recommend that you join us in slack https://rubyforgood.herokuapp.com/ #casa channel to ask questions quickly and hear about office hours (currently Tuesday 6-8pm Pacific), stakeholder news, and upcoming new issues.
}
    response = client.create_issue(repo_name, title, body, labels: ['railsconf2022workshop'])
    issue_number = response[:number]
    p "created issue #{issue_number} for #{filename}"
    ticket_number += 1
  end
end
