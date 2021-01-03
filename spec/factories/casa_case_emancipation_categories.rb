FactoryBot.define do
  factory :casa_case_emancipation_category do
    casa_case do
      create(:casa_case)
    end

    emancipation_category do
      create(:emancipation_category)
    end
  end
end
