require "rails_helper"

RSpec.describe CaseContactsDecorator do
  describe "#display_case_number" do
    context "when the casa case has a case number" do
      context "when transition aged youth is true" do
        it "returns the casa case number with the corresponding transition aged youth icon" do
          org = build(:casa_org)
          admin = create(:casa_admin, casa_org: org)
          case_contact = build(:case_contact)
          casa_case = create(
            :casa_case,
            casa_org: org,
            case_number: "CINA-1234",
            birth_month_year_youth: 15.years.ago
          )

          sign_in admin

          case_contacts = CaseContactsDecorator.decorate({1 => [case_contact]})

          expect(case_contacts.display_case_number(casa_case.id)).to eq("🦋 CINA-1234")
        end
      end

      context "when transition aged youth is false" do
        it "returns the casa case number with the corresponding transition aged youth icon" do
          org = build(:casa_org)
          admin = create(:casa_admin, casa_org: org)
          case_contact = build(:case_contact)
          casa_case = create(
            :casa_case,
            casa_org: org,
            case_number: "CINA-1234",
            birth_month_year_youth: 12.years.ago
          )

          sign_in admin

          case_contacts = CaseContactsDecorator.decorate({1 => [case_contact]})

          expect(case_contacts.display_case_number(casa_case.id)).to eq("🐛 CINA-1234")
        end
      end
    end

    context "when the case case does not have a case number" do
      it "returns an empty string" do
        org = create(:casa_org)
        admin = create(:casa_admin, casa_org: org)
        casa_case = build(:casa_case, casa_org: org, case_number: nil)

        sign_in admin

        case_contacts = CaseContactsDecorator.decorate(nil)

        expect(case_contacts.display_case_number(casa_case.id)).to eq("")
      end
    end
  end

  describe "#boolean_select_options" do
    it "returns an array of options" do
      case_contact = build(:case_contact)

      case_contacts = CaseContactsDecorator.decorate({1 => [case_contact]})

      expect(case_contacts.boolean_select_options).to eq([["Yes", true], ["No", false]])
    end
  end
end
