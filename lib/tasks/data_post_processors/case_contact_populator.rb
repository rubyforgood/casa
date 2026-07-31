module CaseContactPopulator
  def self.populate
    CaseContact.find_each do |case_contact|
      # No casa_case means a DRAFT -- drafts carry draft_case_ids and are only given a casa_case when
      # they are finished. Skip them.
      #
      # This used to `destroy` such a record ("get rid of drafts"), written years before drafts became
      # a real feature, and then dereferenced it anyway -- there was no `next` -- so the task deleted
      # user data and then raised NoMethodError on the first draft it met, taking the whole of
      # `rake after_party:run` down with it (the after-party CI job runs that on a fresh database).
      next unless case_contact.casa_case

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
