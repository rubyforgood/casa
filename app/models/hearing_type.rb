class HearingType < ApplicationRecord
  belongs_to :casa_org
  has_many :checklist_items

  validates :name, presence: true, uniqueness: {scope: %i[casa_org]}

  default_scope { order(name: :asc) }
  scope :for_organization, ->(org) { where(casa_org: org) }
  scope :active, -> { where(active: true) }

  DEFAULT_HEARING_TYPES = [
    "emergency hearing",
    "trial on the merits",
    "scheduling conference",
    "uncontested hearing",
    "pendente lite hearing",
    "pretrial conference"
  ].freeze

  class << self
    def generate_for_org!(casa_org)
      DEFAULT_HEARING_TYPES.each do |hearing_type|
        HearingType.find_or_create_by!(
          casa_org: casa_org,
          name: hearing_type,
          active: true
        )
      end
    end
  end
end

# == Schema Information
#
# Table name: hearing_types
#
#  id                     :bigint           not null, primary key
#  active                 :boolean          default(TRUE), not null
#  checklist_updated_date :string           default("None"), not null
#  name                   :string           not null
#  casa_org_id            :bigint           not null
#
# Indexes
#
#  index_hearing_types_on_casa_org_id  (casa_org_id)
#
