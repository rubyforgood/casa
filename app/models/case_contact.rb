# CaseContact Model
class CaseContact < ApplicationRecord
  attr_accessor :duration_hours

  belongs_to :creator, class_name: 'User'
  belongs_to :casa_case

  validates :contact_type, presence: true

  CONTACT_TYPES = %w[
    youth
    school
    social_worker
    therapist
    attorney
    bio_parent
    foster_parent
    other_family
    supervisor
    court
    other
  ].freeze

  CONTACT_MEDIUMS = %w[
    in-person
    text/email
    video
    voice-only
    letter
  ].freeze
  enum contact_type: CONTACT_TYPES.zip(CONTACT_TYPES).to_h

  def humanized_type
    "#{contact_type.humanize.titleize}#{' - ' + other_type_text if use_other_type_text?}"
  end

  def use_other_type_text?
    contact_type == 'other'
  end

  def self.to_csv
    attributes = report_headers

    CSV.generate(headers: true) do |csv|
      csv << attributes.map(&:titleize)

      all.decorate.each do |case_contact|
        csv << [
          case_contact&.id,
          case_contact&.casa_case&.case_number,
          case_contact&.duration_minutes,
          case_contact&.occurred_at,
          case_contact&.creator&.email,
          'N/A', # case_contact&.creator&.name, Add back in after user has name field
          case_contact&.creator&.supervisor&.email,
          case_contact&.contact_type
        ]
      end
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

# == Schema Information
#
# Table name: case_contacts
#
#  id               :bigint           not null, primary key
#  contact_made     :boolean          default(FALSE)
#  contact_type     :string           not null
#  duration_minutes :integer          not null
#  medium_type      :string
#  occurred_at      :datetime         not null
#  other_type_text  :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  casa_case_id     :bigint           not null
#  creator_id       :bigint           not null
#
# Indexes
#
#  index_case_contacts_on_casa_case_id  (casa_case_id)
#  index_case_contacts_on_creator_id    (creator_id)
#
# Foreign Keys
#
#  fk_rails_...  (casa_case_id => casa_cases.id)
#  fk_rails_...  (creator_id => users.id)
#
