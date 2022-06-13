FactoryBot.define do
  factory :fund_request do
    deadline { "tuesday the 12th of May" }
    extra_information { "extra_information" }
    impact { "impact" }
    other_funding_source_sought { "other_funding_source_sought" }
    payee_name { "payee_name" }
    payment_amount { "$123.45" }
    request_purpose { "shoes" }
    requested_by_and_relationship { "me, the CASA" }
    submitter_email { "casa@example.cmo" }
    youth_name { "The youth Name" }
  end
end
