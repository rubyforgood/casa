class CasaOrg < ApplicationRecord
  validates :name, presence: true, uniqueness: true

  has_many :users
  has_many :casa_cases
  has_one :casa_org_logo, dependent: :destroy

  delegate :url, :alt_text, :size, to: :casa_org_logo, prefix: :logo, allow_nil: true

  def casa_admins
    users.where(type: "CasaAdmin")
  end

  def supervisors
    users.where(type: "Supervisor")
  end

  def volunteers
    users.where(type: "Volunteer")
  end

  def case_contacts
    CaseContact.where(
      casa_case_id: CasaCase.where(casa_org_id: id)
    )
  end
end

# == Schema Information
#
# Table name: casa_orgs
#
#  id           :bigint           not null, primary key
#  address      :string
#  display_name :string
#  footer_links :string           default([]), is an Array
#  name         :string           not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
