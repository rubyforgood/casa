module ContactTopicPopulator
  def self.populate
    CasaOrg.all.each do |casa_org|
      ContactTopic.generate_for_org!(casa_org)
      topics = casa_org.contact_topics
      topics.each do |topic|
        CaseContact.all.each do |contact|
          FactoryBot.create(:contact_topic_answer, case_contact: contact, contact_topic: topic)
        end
      end
    end
  end
end
