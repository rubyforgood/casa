class ContactTopicAnswer < ApplicationRecord
  belongs_to :case_contact
  belongs_to :contact_topic

  validates :selected, inclusion: [true, false]

  default_scope { joins(:contact_topic).order("contact_topics.id") }
end

# == Schema Information
#
# Table name: contact_topic_answers
#
#  id               :bigint           not null, primary key
#  selected         :boolean          default(FALSE), not null
#  value            :text
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  case_contact_id  :bigint           not null
#  contact_topic_id :bigint           not null
#
# Indexes
#
#  index_contact_topic_answers_on_case_contact_id   (case_contact_id)
#  index_contact_topic_answers_on_contact_topic_id  (contact_topic_id)
#
# Foreign Keys
#
#  fk_rails_...  (case_contact_id => case_contacts.id)
#  fk_rails_...  (contact_topic_id => contact_topics.id)
#
