require "rails_helper"
require "rake"

RSpec.describe "prune_login_activities rake task" do
  before(:all) do
    Rails.application.load_tasks if Rake::Task.tasks.empty?
  end

  before(:each) do
    Rake::Task["prune_login_activities"].reenable
  end

  subject(:run_task) { Rake::Task["prune_login_activities"].invoke }

  it "prunes login activities older than 13 months and prints the summary" do
    create(:login_activity, created_at: 14.months.ago)
    create(:login_activity, created_at: 2.months.ago)

    expect { run_task }.to output("Pruned 1 login activity older than 13 months.\n").to_stdout
      .and change(LoginActivity, :count).by(-1)
  end

  it "honours LOGIN_ACTIVITY_RETENTION_MONTHS from ENV" do
    create(:login_activity, created_at: 14.months.ago)

    stub_const("ENV", ENV.to_h.merge("LOGIN_ACTIVITY_RETENTION_MONTHS" => "15"))

    expect { run_task }.to output("Pruned 0 login activities older than 15 months.\n").to_stdout
      .and not_change(LoginActivity, :count)
  end
end
