require "rails_helper"
require "rake"

RSpec.describe "rake task files" do
  it "do not define a top-level Notification constant that breaks Noticed notifiers" do
    Rails.application.load_tasks if Rake::Task.tasks.empty?

    expect(Object.const_defined?(:Notification, false)).to be(false)
    expect(FollowupNotifier::Notification).to be < Noticed::Notification
  end
end
