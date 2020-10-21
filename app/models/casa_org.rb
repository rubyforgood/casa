class CasaOrg < ApplicationRecord
  validates :name, presence: true, uniqueness: true

  has_many :users, dependent: :destroy
  has_many :casa_cases, dependent: :destroy
  has_many :contact_type_groups, dependent: :destroy
  has_one :casa_org_logo, dependent: :destroy
  has_many :hearing_types, dependent: :destroy
  has_one_attached :logo

  delegate :url, :alt_text, :size, to: :casa_org_logo, prefix: :logo, allow_nil: true

  def casa_admins
    CasaAdmin.in_organization(self)
  end

  def supervisors
    Supervisor.in_organization(self)
  end

  def volunteers
    Volunteer.in_organization(self)
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
