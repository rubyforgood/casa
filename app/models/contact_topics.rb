class ContactTopics
  CASA_DEFAULT_COURT_TOPICS = Rails.root.join("data", "default_contact_topics.yml")

  class << self
    def generate_for_org!(casa_org)
      casa_org.contact_topics = default_contact_topics
      casa_org.save!
    end

    private

    def default_contact_topics
      YAML.load_file(CASA_DEFAULT_COURT_TOPICS)
    end
  end
end
