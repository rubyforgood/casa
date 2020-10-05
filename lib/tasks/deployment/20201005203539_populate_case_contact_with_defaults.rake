namespace :after_party do
  desc 'Deployment task: populate_case_contact_with_defaults'
  task populate_case_contact_with_defaults: :environment do
    puts "Running deploy task 'populate_case_contact_with_defaults'"

    CasaOrg.all.each do |org|
      ContactTypeGroup.find_by(casa_org: org, name: "Biological family").update(name: "Family")
      
      ContactTypeGroup.find_by(casa_org: org, name: "Family").tap do |group|
        ContactType.find_by(contact_type_group: group, name: "Bio Parent")&.destroy
        ContactType.find_by(contact_type_group: group, name: "Other Family")&.destroy

        ContactType.create(contact_type_group: group, name: "Parent")
        ContactType.create(contact_type_group: group, name: "Other Family")
        ContactType.create(contact_type_group: group, name: "Sibling")
        ContactType.create(contact_type_group: group, name: "Grandparent")
        ContactType.create(contact_type_group: group, name: "Aunt Uncle or Cousin")
        ContactType.create(contact_type_group: group, name: "Fictive Kin")
      end

      ContactTypeGroup.find_by(casa_org: org, name: "Placement").tap do |group|
        ContactType.create(contact_type_group: group, name: "Caregiver Family")
        ContactType.create(contact_type_group: group, name: "Therapeutic Agency Worker")
      end

      ContactTypeGroup.find_by(casa_org: org, name: "Social Services").tap do |group|
        ContactType.find_by(contact_type_group: group, name: "DSS Worker").destroy
        ContactType.create(contact_type_group: group, name: "Youth")
        ContactType.create(contact_type_group: group, name: "Supervisor")
      end

      ContactTypeGroup.find_by(casa_org: org, name: "Health").tap do |group|
        ContactType.find_by(contact_type_group: group, name: "Therapist").update(name: "Mental Health Therapist")
        ContactType.create(contact_type_group: group, name: "Other Therapist")
        ContactType.create(contact_type_group: group, name: "Psychiatric Practitioner")
      end

      ContactTypeGroup.find_by(casa_org: org, name: "Education").tap do |group|
        ContactType.create(contact_type_group: group, name: "Guidance Counselor")
        ContactType.create(contact_type_group: group, name: "Teacher")
        ContactType.create(contact_type_group: group, name: "IEP Team")
      end
    end

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
