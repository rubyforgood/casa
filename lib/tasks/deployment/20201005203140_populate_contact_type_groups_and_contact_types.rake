namespace :after_party do
  desc 'Deployment task: populate_contact_type_groups_and_contact_types'
  task populate_contact_type_groups_and_contact_types: :environment do
    puts "Running deploy task 'populate_contact_type_groups_and_contact_types'"

    # Create Groups and Contact types for each existing organization
    CasaOrg.all.each do |org|
      ContactTypeGroup.create(casa_org: org, name: "CASA").tap do |group|
        ContactType.create(contact_type_group: group, name: "Youth")
        ContactType.create(contact_type_group: group, name: "Supervisor")
      end

      ContactTypeGroup.create(casa_org: org, name: "Biological family").tap do |group|
        ContactType.create(contact_type_group: group, name: "Bio Parent")
        ContactType.create(contact_type_group: group, name: "Other Family")
      end

      ContactTypeGroup.create(casa_org: org, name: "Placement").tap do |group|
        ContactType.create(contact_type_group: group, name: "Foster Parent")
      end

      ContactTypeGroup.create(casa_org: org, name: "Social Services").tap do |group|
        ContactType.create(contact_type_group: group, name: "Social Worker")
        ContactType.create(contact_type_group: group, name: "DSS Worker")
      end

      ContactTypeGroup.create(casa_org: org, name: "Legal").tap do |group|
        ContactType.create(contact_type_group: group, name: "Court")
        ContactType.create(contact_type_group: group, name: "Attorney")
      end

      ContactTypeGroup.create(casa_org: org, name: "Health").tap do |group|
        ContactType.create(contact_type_group: group, name: "Medical Professional")
        ContactType.create(contact_type_group: group, name: "Therapist")
      end

      ContactTypeGroup.create(casa_org: org, name: "Education").tap do |group|
        ContactType.create(contact_type_group: group, name: "School")
      end

      ContactTypeGroup.create(casa_org: org, name: "Support Worker").tap do |group|
        ContactType.create(contact_type_group: group, name: "Other Support Worker")
      end
    end

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
