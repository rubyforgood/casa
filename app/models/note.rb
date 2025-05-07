class Note < ApplicationRecord
  belongs_to :notable, polymorphic: true
  belongs_to :creator, class_name: "User"
end

# == Schema Information
#
# Table name: notes
#
#  id           :bigint           not null, primary key
#  content      :string
#  notable_type :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  creator_id   :bigint
#  notable_id   :bigint
#
# Foreign Keys
#
#  fk_rails_...  (creator_id => users.id)
#
