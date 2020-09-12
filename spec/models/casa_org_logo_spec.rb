require "rails_helper"

RSpec.describe CasaOrgLogo, type: :model do
  it "has a valid factory" do
    logo = build(:casa_org_logo)
    expect(logo.valid?).to be true
  end
end
