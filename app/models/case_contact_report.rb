class CaseContactReport < ApplicationRecord
  def self.to_csv
    attributes = report_headers

    CSV.generate(headers: true) do |csv|
      csv << attributes.map(&:titleize)

      CaseContact.all.decorate.each { |case_contact| csv << case_contact.attributes_to_array }
    end
  end

  def self.report_headers
    headers = %w[case_contact_id casa_case_number duration occurred_at
                 creator_email creator_name creator_supervisor_name contact_type]

    # TODO: Issue 119 -- Enable multiple contact types for a case_contact
    # headers.concat(CaseContact::CONTACT_TYPES.map { |t| "contact_type: #{t}" })
    headers
  end
end
