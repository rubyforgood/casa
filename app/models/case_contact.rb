# CaseContact Model
class CaseContact < ApplicationRecord
  attr_accessor :duration_hours

  belongs_to :creator, class_name: 'User'
  belongs_to :casa_case

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
  # enum contact_type: CONTACT_TYPES.zip(CONTACT_TYPES).to_h

  validates :contact_types, presence: true
  validate :contact_types_included

  def contact_types_included
    contact_types&.each do |contact_type|
      errors.add(:contact_types, :invalid) unless CONTACT_TYPES.include? contact_type
    end
  end


  # @return [Array<String>]
  def humanized_contact_types
    contact_types&.map { |ct| ct.humanize.titleize }
  end

  def use_other_type_text?
    contact_types.include?('other')
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
      contact_types
    ]
  end
end

# == Schema Information
#
# Table name: case_contacts
#
#  id               :bigint           not null, primary key
#  contact_made     :boolean          default(FALSE)
#  contact_types    :string           is an Array
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
#  index_case_contacts_on_casa_case_id   (casa_case_id)
#  index_case_contacts_on_contact_types  (contact_types) USING gin
#  index_case_contacts_on_creator_id     (creator_id)
#
# Foreign Keys
#
#  fk_rails_...  (casa_case_id => casa_cases.id)
#  fk_rails_...  (creator_id => users.id)
#
