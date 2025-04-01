class UserLanguage < ApplicationRecord
  belongs_to :user
  belongs_to :language

  validates :language, uniqueness: {scope: :user}
end

# == Schema Information
#
# Table name: user_languages
#
#  id          :bigint           not null, primary key
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  language_id :bigint
#  user_id     :bigint
#
# Indexes
#
#  index_user_languages_on_language_id_and_user_id  (language_id,user_id) UNIQUE
#  index_user_languages_on_user_id                  (user_id)
#
