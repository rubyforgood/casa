namespace :after_party do
  desc 'Deployment task: Create default standard court orders for every CASA org'
  task create_default_standard_court_orders: :environment do
    puts "Running deploy task 'create_default_standard_court_orders'"

    # Put your task implementation HERE.
    default_standard_court_orders = [
      "Birth certificate for the Respondent’s",
      "Domestic Violence Education/Group",
      "Educational monitoring for the Respondent",
      "Educational or Vocational referrals",
      "Family therapy",
      "Housing support for the [parent]",
      "Independent living skills classes or workshops",
      "Individual therapy for the [parent]",
      "Individual therapy for the Respondent",
      "Learners’ permit for the Respondent, drivers’ education and driving hours when needed",
      "No contact with (mother, father, other guardian)",
      "Parenting Classes (mother, father, other guardian)",
      "Psychiatric Evaluation and follow all recommendations (child, mother, father, other guardian)",
      "Substance abuse assessment for the [parent]",
      "Substance Abuse Evaluation and follow all recommendations (child, mother, father, other guardian)",
      "Substance Abuse Treatment (child, mother, father, other guardian)",
      "Supervised visits",
      "Supervised visits at DSS",
      "Therapy (child, mother, father, other guardian)",
      "Tutor for the Respondent",
      "Urinalysis (child, mother, father, other guardian)",
      "Virtual Visits",
      "Visitation assistance for the Respondent to see [family]"
    ].freeze

    CasaOrg.all.each do |casa_org|
      create_default_standard_court_orders(casa_org, default_standard_court_orders)
    end

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end

  # TODO: tests!?!
  def create_default_standard_court_orders(casa_org, default_standard_court_orders)
    default_standard_court_orders.each do |order|
      StandardCourtOrder.create(value: order, casa_org: casa_org)
    end
  end
end
