module ContactTypePopulator
  # Create Groups and Contact types for each existing organization
  def self.populate
    CasaOrg.all.each do |org|
      create(org, "CASA", "Youth", "Supervisor")
      create(org, "Family", "Parent", "Other Family", "Sibling", "Grandparent", "Aunt Uncle or Cousin", "Fictive Kin")
      create(org, "Placement", "Foster Parent", "Caregiver Family", "Therapeutic Agency Worker")
      create(org, "Social Services", "Social Worker")
      create(org, "Legal", "Court", "Attorney")
      create(org, "Health", "Medical Professional", "Mental Health Therapist", "Other Therapist", "Psychiatric Practitioner")
      create(org, "Education", "School", "Guidance Counselor", "Teacher", "IEP Team")
    end
  end

  def self.create(org, group_name, *type_names)
    group = ContactTypeGroup.find_or_create_by!(casa_org: org, name: group_name)
    type_names.each { |type_name| ContactType.find_or_create_by!(contact_type_group: group, name: type_name) }
  end
end
