namespace :after_party do
  desc "Deployment task: Populate languages table"
  task populate_languages: :environment do
    puts "Running deploy task 'populate_languages'"

    # Put your task implementation HERE.
    CasaOrg.all.each do |casa_org|
      create_languages(casa_org)
    end
    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end

  def create_languages(casa_org)
    create_language("Spanish", casa_org)
    create_language("Vietnamese", casa_org)
    create_language("French", casa_org)
    create_language("Chinese Cantonese", casa_org)
    create_language("ASL", casa_org)
    create_language("Other", casa_org)
  end

  def create_language(name, casa_org)
    Language.find_or_create_by!(name: name, casa_org: casa_org)
  end
end
