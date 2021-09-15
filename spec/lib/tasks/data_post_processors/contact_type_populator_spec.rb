require "rails_helper"

RSpec.describe "populates each existing organization with contact groups and types" do
  before do
    Rake::Task.clear
    Casa::Application.load_tasks
  end

  it "creates the expected contact groups and contact types for each existing organization" do
    ContactTypePopulator.populate

    CasaOrg.all.each do |org|
      casa_group = org.contact_type_groups.find_by(name: "CASA")
      expect(casa_group.contact_types.pluck(:name)).to contain_exactly("Youth", "Supervisor")

      family_group = org.contact_type_groups.find_by(name: "Family")
      expect(family_group.contact_types.pluck(:name)).to contain_exactly("Parent", "Other Family", "Sibling", "Grandparent", "Aunt Uncle or Cousin", "Fictive Kin")

      placement_group = org.contact_type_groups.find_by(name: "Placement")
      expect(placement_group.contact_types.pluck(:name)).to contain_exactly("Foster Parent", "Caregiver Family", "Therapeutic Agency Worker")

      social_services_group = org.contact_type_groups.find_by(name: "Social Services")
      expect(social_services_group.contact_types.pluck(:name)).to contain_exactly("Social Worker")

      legal_group = org.contact_type_groups.find_by(name: "Legal")
      expect(legal_group.contact_types.pluck(:name)).to contain_exactly("Court", "Attorney")

      health_group = org.contact_type_groups.find_by(name: "Health")
      expect(health_group.contact_types.pluck(:name)).to contain_exactly("Medical Professional", "Mental Health Therapist", "Other Therapist", "Psychiatric Practitioner")

      education_group = org.contact_type_groups.find_by(name: "Education")
      expect(education_group.contact_types.pluck(:name)).to contain_exactly("School", "Guidance Counselor", "Teacher", "IEP Team")
    end
  end
end
