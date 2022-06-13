# frozen_string_literal: true

namespace :after_party do
  desc "Deployment task: enable_feature_flag_prince_george_fund_request.rake"
  task enable_feature_flag_prince_george_fund_request: :environment do
    puts "Running deploy task 'enable_feature_flag_prince_george_fund_request'"

    casa_org = CasaOrg.find_by(name: "Prince George CASA")
    casa_org&.update!(show_fund_request: true)

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
