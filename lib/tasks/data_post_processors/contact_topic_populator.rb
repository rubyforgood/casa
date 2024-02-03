module ContactTopicPopulator
  def self.populate
    CasaOrg.all.each do |casa_org|
      ContactTopics.generate_for_org!(casa_org)
    end
  end
end
