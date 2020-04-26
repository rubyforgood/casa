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
  ].freeze

  CONTACT_MEDIUMS = %w[in-person text/email video voice-only letter].freeze
  enum contact_type: CONTACT_TYPES.zip(CONTACT_TYPES).to_h

  def humanized_type
    "#{contact_type.humanize.titleize}"
  end

  # Generate array of attributes for All Case Contacts report
  def attributes_to_array
    [
      id,
      casa_case&.case_number,
      duration_minutes,
      occurred_at,
      creator&.email,
      'N/A',
      # creator&.name, Add back in after user has name field
      creator&.supervisor&.email,
      contact_type
    ]
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
