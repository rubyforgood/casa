namespace :after_party do
  desc "Deployment task: adds_new_emancipation_category_options"
  task emancipation_category_options: :environment do
    puts "Running deploy task 'emancipation_category_options'"

    category_employment = EmancipationCategory.where(name: "Youth is employed.")
      .first_or_create(mutually_exclusive: true)
    category_employment.add_option("Not employed")

    category_continuing_education = EmancipationCategory.where(name: "Youth is attending an educational or vocational program.")
      .first_or_create(mutually_exclusive: true)
    category_continuing_education.add_option("Not attending")

    category_high_school_diploma = EmancipationCategory.where(name: "Youth has a high school diploma or equivalency.")
      .first_or_create(mutually_exclusive: true)
    category_high_school_diploma.add_option("No")

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
