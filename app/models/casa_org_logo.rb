class CasaOrgLogo < ApplicationRecord
  belongs_to :casa_org
end

# == Schema Information
#
# Table name: casa_org_logos
#
#  id           :bigint           not null, primary key
#  alt_text     :string
#  banner_color :string
#  size         :string
#  url          :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  casa_org_id  :bigint           not null
#
# Indexes
#
#  index_casa_org_logos_on_casa_org_id  (casa_org_id)
#
# Foreign Keys
#
#  fk_rails_...  (casa_org_id => casa_orgs.id)
#
