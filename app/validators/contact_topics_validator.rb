class ContactTopicsValidator < ActiveModel::Validator
  PERMITTED_ATTRIBUTES = %w[title details active].freeze

  def validate(source)
    contact_topics = Array.wrap(source.contact_topics)

    contact_topics.each do |topic|
      if !topic.is_a?(Hash)
        source.errors.add(:contact_topics, "must be a hash or array of hashes")
      elsif (topic.keys - PERMITTED_ATTRIBUTES).any?
        source.errors.add(:contact_topics,
          "expected keys: #{PERMITTED_ATTRIBUTES.join(", ")} got keys: #{topic.keys}")
      end
    end
  end
end
