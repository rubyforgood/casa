module ContactTypePopulator
  def self.populate
    CasaOrg.all.each do |casa_org|
      ContactTypeGroup.generate_for_org!(casa_org)
    end
  end
end
