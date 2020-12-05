FactoryBot.define do
  factory :casa_cases_emancipation_option do
    casa_case do
      create(:casa_case)
    end

    emancipation_option do
      create(:emancipation_option)
    end
  end
end
