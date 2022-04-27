namespace :after_party do
  desc 'Deployment task: enable_prince_george_fund_request'
  task enable_prince_george_fund_request: :environment do
    puts "Running deploy task 'enable_prince_george_fund_request'"

    casa_org = CasaOrg.find_by(name: "Prince George CASA")
    if casa_org
      casa_org.update!(show_fund_request: true)
    end

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
        .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
