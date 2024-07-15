module Deployment
  class CreateDefaultStandardCourtOrdersService
    DEFAULT_STANDARD_COURT_ORDERS = [
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

    def create_defaults
      CasaOrg.all.each do |casa_org|
        DEFAULT_STANDARD_COURT_ORDERS.each do |order|
          StandardCourtOrder.create(value: order, casa_org: casa_org)
        end
      end
    end
  end
end