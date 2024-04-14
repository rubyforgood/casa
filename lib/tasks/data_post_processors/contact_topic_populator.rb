module ContactTopicPopulator
  def self.populate
    CasaOrg.all.each do |casa_org|
      ContactTopic.generate_for_org!(casa_org)

      casa_org.contact_topics.each do |topic|
        org_case_contacts = CaseContact.joins(:casa_case).where("casa_case.casa_org_id": casa_org.id)
        org_case_contacts.each do |contact|
          FactoryBot.create(:contact_topic_answer, case_contact: contact, contact_topic: topic)
        end
      end
    end
  end
end
