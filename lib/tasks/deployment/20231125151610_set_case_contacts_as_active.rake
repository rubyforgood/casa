namespace :after_party do
  desc "Deployment task: set_case_contacts_as_active"
  task set_case_contacts_as_active: :environment do
    puts "Running deploy task 'set_case_contacts_as_active'"

    CaseContact.where.not(casa_case_id: nil).each do |cc|
      cc.additional_expenses.each do |additional_expense|
        additional_expense.update(other_expenses_describe: "No description given") unless additional_expense.other_expenses_describe
      end
      cc.update(status: "active", draft_case_ids: [cc.casa_case_id])
    end

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
