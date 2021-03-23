require "rails_helper"

RSpec.describe CasaOrg, type: :model do
  it { is_expected.to validate_presence_of(:name) }

  it "has unique name" do
    org = create(:casa_org)
    new_org = build(:casa_org, name: org.name)
    expect(new_org.valid?).to be false
  end

  describe "Attachment" do
    it "is valid" do
      aggregate_failures do
        expect(subject.org_logo).to eq(Pathname.new("#{Rails.root}/public/logo.jpeg"))
        subject.logo.attach(io: File.open("#{Rails.root}/spec/fixtures/company_logo.png"),
                            filename: "company_logo.png", content_type: "logo/png")
        expect(subject.logo).to be_attached
        expect(subject.org_logo).to_not eq(Pathname.new("#{Rails.root}/public/logo.jpeg"))
      end
    end
  end
end
