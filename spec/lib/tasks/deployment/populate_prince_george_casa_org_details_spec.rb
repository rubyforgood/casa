require "rails_helper"

RSpec.describe "populate prince george org details" do
  setup { Casa::Application.load_tasks }

  it "creates an org with correct details if DB is empty" do
    expect {
      Rake::Task["after_party:populate_prince_george_casa_org_details"].invoke
    }.to change(AfterParty::TaskRecord, :count).by(2)
    Rake::Task["after_party:populate_prince_george_casa_org_details"].reenable
    casa_org = CasaOrg.find_by(name: "Prince George CASA")
    aggregate_failures do
      expect(casa_org.display_name).to eq("CASA / Prince George's County, MD")
      expect(casa_org.address).to eq("6811 Kenilworth Avenue, Suite 402 Riverdale, MD 20737")
      expect(casa_org.footer_links.length).to eq 3
      expect(casa_org.casa_org_logo.alt_text).to eq "CASA Logo"
    end
  end

  it "updates an existing org with correct details" do
    CasaOrg.create!(name: "Prince George CASA",
                    display_name: "Bad Name",
                    address: "123 Main St",
                    footer_links: "boop!")
    expect {
      Rake::Task["after_party:populate_prince_george_casa_org_details"].invoke
    }.to change(AfterParty::TaskRecord, :count).by(1)
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
