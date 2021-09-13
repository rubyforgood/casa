module ContactTypePopulator
  BASIC_CONTACT_TYPES = {
    CASA: ["Youth", "Supervisor"],
    Family: ["Parent", "Other Family", "Sibling", "Grandparent", "Aunt Uncle or Cousin", "Fictive Kin"],
    Placement: ["Foster Parent", "Caregiver Family", "Therapeutic Agency Worker"],
    "Social Services": ["Social Worker"],
    Legal: ["Court", "Attorney"],
    Health: ["Medical Professional", "Mental Health Therapist", "Other Therapist", "Psychiatric Practitioner"],
    Education: ["School", "Guidance Counselor", "Teacher", "IEP Team"]
  }.freeze

  def self.populate
    CasaOrg.all.each do |casa_org|
      BASIC_CONTACT_TYPES.each do |contact_group_name, contact_type_names|
        group = ContactTypeGroup.find_or_create_by!(casa_org: casa_org, name: contact_group_name)
        contact_type_names.each do |type_name|
          ContactType.find_or_create_by!(contact_type_group: group, name: type_name)
        end
      end
    end
  end
end
