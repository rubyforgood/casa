namespace :after_party do
  desc "Deployment task: Generate slugs for existing records so they can be accessed with their new slug based routes"
  task populate_slugs_for_orgs_and_cases: :environment do
    puts "Running deploy task 'populate_slugs_for_orgs_and_cases'"
    puts "task deleted because it uses the now-uncallable method set_slug"

    # Put your task implementation HERE.
    # CasaOrg.all.each do |org|
    #   org.set_slug
    #   org.save
    # end
    #
    # CasaCase.all.each do |casa_case|
    #   casa_case.set_slug
    #   casa_case.save
    # end

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
