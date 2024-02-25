namespace :after_party do
  desc "Deployment task: set_case_contacts_as_active"
  task set_case_contacts_as_active: :environment do
    puts "Running deploy task 'set_case_contacts_as_active'"

    CaseContact.where.not(casa_case_id: nil).each do |cc|
      p cc.id
      cc.additional_expenses.each do |additional_expense|
        additional_expense.update!(other_expenses_describe: "No description given") unless additional_expense.other_expenses_describe
      end

      cc.update!(status: "active", draft_case_ids: [cc.casa_case_id])
    rescue => e
      begin
        require "bugsnag"
        Bugsnag.configure do |config|
          config.api_key = ENV["BUGSNAG_API_KEY"]
          config.ignore_classes << ActiveRecord::RecordNotFound
          config.release_stage = ENV["HEROKU_APP_NAME"] || ENV["APP_ENVIRONMENT"]

          callback = proc do |event|
            event.set_user(current_user&.id, current_user&.email)
          end

          config.add_on_error(callback)
        end

        Bugsnag.notify(e)
      rescue => e2
        p e2
      end
      p e
    end

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
