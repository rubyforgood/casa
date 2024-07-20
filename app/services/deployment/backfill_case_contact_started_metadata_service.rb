module Deployment
  class BackfillCaseContactStartedMetadataService
    def backfill_metadata
      case_contacts = CaseContact.where("metadata->'status' IS NOT NULL AND metadata->'status'->'started' IS NULL")

      case_contacts.each do |case_contact|
        case_contact.metadata["status"]["started"] = case_contact.created_at.as_json
        case_contact.save!
      end
    end
  end
end
