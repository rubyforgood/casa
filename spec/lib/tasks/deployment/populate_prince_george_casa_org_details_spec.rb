require "rails_helper"

RSpec.describe "populate prince george org details" do
  setup { Casa::Application.load_tasks }

  it "creates and updates an existing org with correct details" do
    Rake::Task["after_party:populate_prince_george_casa_org_details"].invoke
    Rake::Task["after_party:populate_prince_george_casa_org_details"].reenable
    casa_org = CasaOrg.find_by(name: "Prince George CASA")
    aggregate_failures do
      expect(casa_org.display_name).to eq("CASA / Prince George's County, MD")
      expect(casa_org.address).to eq("6811 Kenilworth Avenue, Suite 402 Riverdale, MD 20737")
      expect(casa_org.footer_links.length).to eq 3
      expect(casa_org.casa_org_logo.alt_text).to eq "CASA Logo"
    end
  end
end
