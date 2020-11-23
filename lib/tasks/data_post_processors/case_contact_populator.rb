module CaseContactPopulator
  def self.populate
    code_to_name_mapping = {
      attorney: "Attorney",
      bio_parent: "Bio Parent",
      court: "Court",
      dss_worker: "DSS Worker",
      foster_parent: "Foster Parent",
      medical_professional: "Medical Professional",
      other_family: "Other Family",
      other_support_worker: "Other Support Worker",
      school: "School",
      social_worker: "Social Worker",
      supervisor: "Supervisor",
      therapist: "Therapist",
      youth: "Youth"
    }

    # TODO write a TEST for this
    # TODO make this more performant while still respecting casa_org association- maybe a hash of group name to org to contact type?
    CaseContact.find_each do |case_contact|
      casa_org = case_contact.casa_case.casa_org
      case_contact.contact_types&.each do |contact_type|
        ct_name = code_to_name_mapping[contact_type.to_sym]
        cts_by_name = ContactType.where(name: ct_name)
        ct = cts_by_name.find { |ct| ct.contact_type_group.casa_org == casa_org }
        unless ct
          if cts_by_name.any?
            ctg_name = cts_by_name.first.contact_type_group.name
            org_ctg = ContactTypeGroup.where(casa_org: casa_org, name: ctg_name)
            if org_ctg
              ContactType.find_or_create_by!(contact_type_group: org_ctg, name: ct_name)
            else
              ContactTypeGroup.find_or_create_by!(casa_org: casa_org, name: ctg_name)
            end
          else
            new_ctg = ContactTypeGroup.find_or_create_by!(casa_org: casa_org, name: "#{ctg_name} Group")
            ContactType.find_or_create_by!(contact_type_group: new_ctg, name: ct_name)
          end
        end
      end
    end
  end
end
