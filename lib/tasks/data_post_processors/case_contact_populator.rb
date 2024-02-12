module CaseContactPopulator
  def self.populate
    CaseContact.find_each do |case_contact|
      # Get rid of drafts
      unless case_contact.casa_case
        case_contact.destroy
      end
      casa_org = case_contact.casa_case.casa_org
      case_contact.contact_types&.each do |contact_type|
        ct_name = contact_type.name
        cts_by_name = ContactType.where(name: ct_name)
        ct = cts_by_name.find { |ct| ct.contact_type_group.casa_org == casa_org }
        unless ct
          if cts_by_name.any?
            ctg_name = cts_by_name.first.contact_type_group.name
            org_ctg = ContactTypeGroup.find_by(casa_org: casa_org, name: ctg_name)
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
