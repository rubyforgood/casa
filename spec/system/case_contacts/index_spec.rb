require "rails_helper"

RSpec.describe "case_contacts/index", js: true, type: :system do
  let(:volunteer) { build(:volunteer, display_name: "Bob Loblaw", casa_org: organization) }
  let(:organization) { create(:casa_org) }

  context "with case contacts" do
    let(:casa_case) { build(:casa_case, casa_org: organization, case_number: "CINA-1") }
    let!(:case_assignment) { create(:case_assignment, volunteer: volunteer, casa_case: casa_case) }

    context "without filter" do
      let(:case_contacts) do
        [
          create(:case_contact, creator: volunteer, casa_case: casa_case, occurred_at: Time.zone.yesterday - 1),
          create(:case_contact, creator: volunteer, casa_case: casa_case, occurred_at: Time.zone.yesterday),
          create(:case_contact, creator: volunteer, casa_case: casa_case, occurred_at: Time.zone.today)
        ]
      end

      it "can see case creator in card" do
        case_contacts
        sign_in volunteer
        visit case_contacts_path
        expect(page).to have_text("Bob Loblaw")
      end

      it "can navigate to edit volunteer page" do
        case_contacts
        sign_in volunteer
        visit case_contacts_path
        expect(page).to have_no_link("Bob Loblaw")
      end

      it "displays the contact type groups" do
        case_contacts
        sign_in volunteer
        visit case_contacts_path
        within(".card-title", match: :first) do
          expect(page).to have_text(case_contacts[2].contact_groups_with_types.keys.first)
        end
      end

      it "sorts case_contacts by occurred_at attribute (default)" do
        case_contacts
        sign_in volunteer
        visit case_contacts_path

        aggregate_failures do
          expect(page.body.index(case_contacts[2].decorate.subheading)).to be < page.body.index(case_contacts[1].decorate.subheading)
          expect(page.body.index(case_contacts[1].decorate.subheading)).to be < page.body.index(case_contacts[0].decorate.subheading)
        end
      end
    end

    describe "filtering case contacts" do
      describe "by date of contact" do
        it "only shows the contacts with the correct date" do
          travel_to Date.new(2021, 1, 2) do
            create(:case_contact, creator: volunteer, casa_case: casa_case, occurred_at: Time.zone.yesterday - 1)
            create(:case_contact, creator: volunteer, casa_case: casa_case, occurred_at: Time.zone.yesterday)
            create(:case_contact, creator: volunteer, casa_case: casa_case, occurred_at: Time.zone.today)

            sign_in volunteer
            visit case_contacts_path
            click_button "Show / Hide"

            fill_in "filterrific_occurred_starting_at", with: Time.zone.yesterday.to_s
            fill_in "filterrific_occurred_ending_at", with: Time.zone.tomorrow.to_s

            click_button "Filter"

            expect(page).not_to have_content "December 31, 2020"
            expect(page).to have_content "January 1, 2021"
            expect(page).to have_content "January 2, 2021"
          end
        end
      end
    end

    describe "case contacts text color" do
      let(:contact_group_text) { case_contact.contact_groups_with_types.keys.first }

      context "with active case contact" do
        let!(:case_contact) { create(:case_contact, creator: volunteer, casa_case: casa_case, occurred_at: Time.zone.yesterday) }

        before do
          sign_in volunteer
          visit case_contacts_path
        end

        it "displays correct color for contact" do
          within ".card-title" do
            title = find("strong.text-primary")
            expect(title).to have_content(contact_group_text)
          end
        end
      end
    end
  end

  context "without case contacts" do
    before(:each) do
      sign_in volunteer
      visit case_contacts_path
    end
    it "shows helper text" do
      expect(page).to have_text("You have no case contacts for this case. Please click New Case Contact button above to create a case contact for your youth!")
    end
  end
end
