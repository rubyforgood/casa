class ContactTopic < ApplicationRecord
  CASA_DEFAULT_COURT_TOPICS = Rails.root.join("db", "seeds", "default_contact_topics.yml")
  belongs_to :casa_org

  has_many :contact_topic_answers

  validates :active, inclusion: [true, false]
  validates :soft_delete, inclusion: [true, false]
  validates :question, presence: true
  validates :details, presence: true

  scope :active, -> { where(active: true, soft_delete: false) }

  scope :with_answers_in, ->(case_contacts_scope) do
    # unscope order in case it collides with distinct
    case_contact_ids = case_contacts_scope.unscope(:order).select(:id).distinct

    # AR will use the query above as a subquery within this one's where clause, ie:
    ContactTopic                                    # select …
      .joins(contact_topic_answers: :case_contact)  # from contact_topics inner join contact_topics …
      .where(case_contact: {id: case_contact_ids})  # where case_contact.id in (select distinct case_contacts.id from …
  end

  class << self
    def generate_for_org!(casa_org)
      default_contact_topics.each do |topic|
        ContactTopic.find_or_create_by!(
          casa_org:, question: topic["question"], details: topic["details"]
        )
      end
    end

    private

    def default_contact_topics
      YAML.load_file(CASA_DEFAULT_COURT_TOPICS)
    end
  end
end

# == Schema Information
#
# Table name: contact_topics
#
#  id          :bigint           not null, primary key
#  active      :boolean          default(TRUE), not null
#  details     :text
#  question    :string
#  soft_delete :boolean          default(FALSE), not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  casa_org_id :bigint           not null
#
# Indexes
#
#  index_contact_topics_on_casa_org_id  (casa_org_id)
#
# Foreign Keys
#
#  fk_rails_...  (casa_org_id => casa_orgs.id)
#
