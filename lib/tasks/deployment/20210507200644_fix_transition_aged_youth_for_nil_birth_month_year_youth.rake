namespace :after_party do
  desc "Deployment task: fix_transition_aged_youth_for_nil_birth_month_year_youth"
  task fix_transition_aged_youth_for_nil_birth_month_year_youth: :environment do
    unless Rails.env.production?
      puts "Running deploy task 'fix_transition_aged_youth_for_nil_birth_month_year_youth'"

      CasaCase
        .where(transition_aged_youth: true)
        .where(birth_month_year_youth: nil)
        .update(transition_aged_youth: false)
    end
    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
