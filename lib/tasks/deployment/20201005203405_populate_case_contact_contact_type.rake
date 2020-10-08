namespace :after_party do
  desc 'Deployment task: populate_case_contact_contact_type'
  task populate_case_contact_contact_type: :environment do
    puts "Running deploy task 'populate_case_contact_contact_type'"

    code_to_name_mapping = {
      attorney: ContactType.where(name: "Attorney").first,
      bio_parent: ContactType.where(name: "Bio Parent").first,
      court: ContactType.where(name: "Court").first,
      dss_worker: ContactType.where(name: "DSS Worker").first,
      foster_parent: ContactType.where(name: "Foster Parent").first,
      medical_professional: ContactType.where(name: "Medical Professional").first,
      other_family: ContactType.where(name: "Other Family").first,
      other_support_worker: ContactType.where(name: "Other Support Worker").first,
      school: ContactType.where(name: "School").first,
      social_worker: ContactType.where(name: "Social Worker").first,
      supervisor: ContactType.where(name: "Supervisor").first,
      therapist: ContactType.where(name: "Therapist").first,
      youth: ContactType.where(name: "Youth").first
    }

    # Point case_contact to contact_types
    CaseContact.find_each do |case_contact|
      case_contact.contact_types&.each do |contact_type|
        CaseContactContactType.find_or_create_by!(
          case_contact: case_contact,
          contact_type: code_to_name_mapping[contact_type.to_sym]
        )
      end
    end

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
