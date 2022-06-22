require 'octokit' # gem install octokit
GITHUB_ACCESS_TOKEN = ENV["GITHUB_ACCESS_TOKEN"]
client = Octokit::Client.new(:access_token => GITHUB_ACCESS_TOKEN)
# repo_name = 'compwron/practice-ticket-creation'
repo_name = 'rubyforgood/casa'

require 'pry'

def in_skip_lines?(line_without_linebreak)
  [
      "channels/application_cable/channel.rb"
  ].any? { |x| x.include?(line_without_linebreak) }
end

File.readlines(".allow_skipping_tests").each do |line|
  line_without_linebreak = line.strip
  if File.exist?("app/" + line_without_linebreak)

    if in_skip_lines?(line_without_linebreak)
      p "SHOULD SKIP #{line_without_linebreak}"
    else
      title = "Add test for #{line_without_linebreak}"
      expected_test_file_path = line_without_linebreak.gsub("app", "spec").gsub(".rb", "_spec.rb")
      class_name = line_without_linebreak.split("/").last.gsub(".rb", "").split('_').map { |e| e.capitalize }.join
      body = %Q{Thank you for working on CASA!

To complete this issue:
1. open `#{line_without_linebreak}`
1. make a new test file: #{expected_test_file_path}
1. add at least one test for the functionality in #{line_without_linebreak}!
1. remove the line #{line_without_linebreak} from `.allow_skipping_tests`

This will improve our test coverage and make our code safer to modify and easier to understand.

Example:

```
Before:
require "rails_helper"

RSpec.describe #{class_name} do
  it "adds the numbers" do
    expect(described_class.new(1, 1)).to eq(2)
  end
end
```

### Questions? Join Slack!

We highly recommend that you join us in slack https://rubyforgood.herokuapp.com/ #casa channel to ask questions quickly and hear about office hours (currently Tuesday 6-8pm Pacific), stakeholder news, and upcoming new issues.
}

      response = client.create_issue(repo_name, title, body, labels: ['testing'])
      issue_number = response[:number]
      p "created issue #{issue_number} for #{line_without_linebreak}"
    end
  end
end