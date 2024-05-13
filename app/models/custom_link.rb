class CustomLink < ApplicationRecord
  belongs_to :casa_org
end

# == Schema Information
#
# Table name: custom_links
#
#  id          :bigint           not null, primary key
#  text        :string
#  url         :text
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  casa_org_id :bigint           not null
#
# Indexes
#
#  index_custom_links_on_casa_org_id  (casa_org_id)
#
# Foreign Keys
#
#  fk_rails_...  (casa_org_id => casa_orgs.id)
#
