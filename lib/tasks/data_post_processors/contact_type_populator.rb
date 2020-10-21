module ContactTypePopulator
  def self.populate
    # Create Groups and Contact types for each existing organization
    # CasaOrg.all.each do |org|
    CasaOrg.all.each do |org|
      # require 'pry'; binding.pry

      ContactTypeGroup.find_or_create_by!(casa_org: org, name: "CASA").tap do |group|
        ContactType.find_or_create_by!(contact_type_group: group, name: "Youth")
        ContactType.find_or_create_by!(contact_type_group: group, name: "Supervisor")
      end

      # require 'pry'; binding.pry

      ContactTypeGroup.find_or_create_by!(casa_org: org, name: "Family").tap do |group|
        ContactType.find_or_create_by!(contact_type_group: group, name: "Parent")
        ContactType.find_or_create_by!(contact_type_group: group, name: "Other Family")
        ContactType.find_or_create_by!(contact_type_group: group, name: "Sibling")
        ContactType.find_or_create_by!(contact_type_group: group, name: "Grandparent")
        ContactType.find_or_create_by!(contact_type_group: group, name: "Aunt Uncle or Cousin")
        ContactType.find_or_create_by!(contact_type_group: group, name: "Fictive Kin")
      end

      ContactTypeGroup.find_or_create_by!(casa_org: org, name: "Placement").tap do |group|
        ContactType.find_or_create_by!(contact_type_group: group, name: "Foster Parent")
        ContactType.find_or_create_by!(contact_type_group: group, name: "Caregiver Family")
        ContactType.find_or_create_by!(contact_type_group: group, name: "Therapeutic Agency Worker")
      end

      ContactTypeGroup.find_or_create_by!(casa_org: org, name: "Social Services").tap do |group|
        ContactType.find_or_create_by!(contact_type_group: group, name: "Social Worker")
      end

      ContactTypeGroup.find_or_create_by!(casa_org: org, name: "Legal").tap do |group|
        ContactType.find_or_create_by!(contact_type_group: group, name: "Court")
        ContactType.find_or_create_by!(contact_type_group: group, name: "Attorney")
      end

      ContactTypeGroup.find_or_create_by!(casa_org: org, name: "Health").tap do |group|
        ContactType.find_or_create_by!(contact_type_group: group, name: "Medical Professional")
        ContactType.find_or_create_by!(contact_type_group: group, name: "Mental Health Therapist")
        ContactType.find_or_create_by!(contact_type_group: group, name: "Other Therapist")
        ContactType.find_or_create_by!(contact_type_group: group, name: "Psychiatric Practitioner")
      end

      ContactTypeGroup.find_or_create_by!(casa_org: org, name: "Education").tap do |group|
        ContactType.find_or_create_by!(contact_type_group: group, name: "School")
        ContactType.find_or_create_by!(contact_type_group: group, name: "Guidance Counselor")
        ContactType.find_or_create_by!(contact_type_group: group, name: "Teacher")
        ContactType.find_or_create_by!(contact_type_group: group, name: "IEP Team")
      end
    end
  end
end