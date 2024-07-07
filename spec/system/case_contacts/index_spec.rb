require "rails_helper"

RSpec.describe "case_contacts/index", js: true, type: :system do
  let(:volunteer) { build(:volunteer, display_name: "Bob Loblaw", casa_org: organization) }
  let(:organization) { create(:casa_org) }

  context "with case contacts" do
    let(:case_number) { "CINA-1" }
    let(:casa_case) { build(:casa_case, casa_org: organization, case_number: case_number) }
    let!(:case_assignment) { create(:case_assignment, volunteer: volunteer, casa_case: casa_case) }

    context "without filter" do
      let(:case_contacts) do
        [
          create(:case_contact, creator: volunteer, casa_case: casa_case, occurred_at: 2.days.ago),
          create(:case_contact, creator: volunteer, casa_case: casa_case, occurred_at: 1.days.ago),
          create(:case_contact, creator: volunteer, casa_case: casa_case, occurred_at: Time.zone.now,
            contact_types: [create(:contact_type, name: "Most Recent Case Contact")]),
          create(:case_contact, :started_status, creator: volunteer, casa_case: casa_case, occurred_at: 3.days.ago,
            contact_types: [create(:contact_type, name: "DRAFT Case Contact")])
        ]
      end

      it "can see case creator in card" do
        case_contacts
        sign_in volunteer
        visit case_contacts_path
        within(".full-card", match: :first) do
          expect(page).to have_text("Bob Loblaw")
        end
      end

      it "can navigate to edit volunteer page" do
        case_contacts
        sign_in volunteer
        visit case_contacts_path
        expect(page).to have_no_link("Bob Loblaw")
      end

      it "allows the volunteer to delete a draft they created" do
        case_contacts
        sign_in volunteer
        visit case_contacts_path

        card = find(".container-fluid.mb-1", text: "DRAFT Case Contact")
        expect(card).to_not be_nil

        within_element(card) do
          expect(card).to have_text("Draft")
          click_link "Delete"
        end

        expect(page).to_not have_css(".container-fluid.mb-1", text: "DRAFT Case Contact")
      end

      it "displays the contact type groups" do
        case_contacts
        sign_in volunteer
        visit case_contacts_path
        expect(page).to have_text("Most Recent Case Contact")
        expect(page).to have_text("DRAFT Case Contact")
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
            click_button "Expand / Hide"

            fill_in "filterrific_occurred_starting_at", with: Time.zone.yesterday
            fill_in "filterrific_occurred_ending_at", with: Time.zone.tomorrow

            click_button "Filter"

            expect(page).not_to have_content "December 31, 2020"
            expect(page).to have_content "January 1, 2021"
            expect(page).to have_content "January 2, 2021"
          end
        end
      end

      describe "by casa_case_id" do
        let!(:case_contact) { create(:case_contact, :details_status, creator: volunteer, draft_case_ids: [casa_case.id]) }
        let!(:other_casa_case) { create(:casa_case, casa_org: organization, case_number: "CINA-2") }

        it "displays the draft" do
          sign_in volunteer
          visit case_contacts_path(casa_case_id: casa_case.id)

          expect(page).not_to have_content "You have no case contacts for this case."
          expect(page).to have_content "Draft"
        end

        it "only displays the filtered case" do
          sign_in volunteer
          visit case_contacts_path(casa_case_id: casa_case.id)

          expect(page).not_to have_content other_casa_case.case_number
          expect(page).to have_content casa_case.case_number
        end
      end

      describe "by hide drafts" do
        it "does not show draft contacts" do
          create(:case_contact, creator: volunteer, casa_case: casa_case)
          create(:case_contact, :started_status, creator: volunteer, casa_case: casa_case)

          sign_in volunteer
          visit case_contacts_path

          check "Hide drafts"

          click_button "Filter"

          expect(page).not_to have_content "Draft"
        end
      end

      describe "collapsing filter menu" do
        before do
          sign_in volunteer
          visit case_contacts_path
        end

        it "displays sticky filters before clicking expand" do
          expect(page).to have_field "Hide drafts", type: :checkbox
        end

        it "does not expand menu when filtering only by sticky filter" do
          check "Hide drafts"

          click_button "Filter"

          expect(page).to have_field "Hide drafts", type: :checkbox
          expect(page).not_to have_content "Other filters"
        end

        it "displays other filters when expanded" do
          click_button "Expand / Hide"

          expect(page).to have_content "Other filters"
        end

        it "does not hide menu when filtering by placement filter" do
          click_button "Expand / Hide"
          select "In Person", from: "Contact medium"

          click_button "Filter"

          expect(page).to have_content "Other filters"
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

    it "can show only case contacts for one case" do
      travel_to Date.new(2021, 1, 2) do
        create(:case_contact, creator: volunteer, casa_case: casa_case, notes: "Case 1 Notes", occurred_at: Time.zone.yesterday - 1)

        another_case_number = "CINA-2"
        another_case = create(:casa_case, casa_org: organization, case_number: another_case_number)
        create(:case_assignment, volunteer: volunteer, casa_case: another_case)
        create(:case_contact, creator: volunteer, casa_case: another_case, notes: "Case 2 Notes", occurred_at: Time.zone.today)

        sign_in volunteer

        # showing all cases
        visit root_path
        click_on "Case Contacts"
        within "#ddmenu_case-contacts" do
          click_on "All"
        end
        expect(page).to have_text("Case 1 Notes")
        expect(page).to have_text("Case 2 Notes")

        # showing case 1
        visit root_path
        click_on "Case Contacts"
        within "#ddmenu_case-contacts" do
          click_on case_number
        end
        expect(page).to have_text("Case 1 Notes")
        expect(page).to_not have_text("Case 2 Notes")

        # showing case 2
        visit root_path
        click_on "Case Contacts"
        within "#ddmenu_case-contacts" do
          click_on another_case_number
        end
        expect(page).to have_text("Case 2 Notes")
        expect(page).to_not have_text("Case 1 Notes")

        # filtering to only show case 2
        click_button "Expand / Hide"
        fill_in "filterrific_occurred_starting_at", with: Time.zone.yesterday
        fill_in "filterrific_occurred_ending_at", with: Time.zone.tomorrow
        click_button "Filter"
        expect(page).to have_text("Case 2 Notes")
        expect(page).to_not have_text("Case 1 Notes")

        # no contacts because we're only showing case 1 and that occurred before the filter dates
        visit root_path
        click_on "Case Contacts"
        within "#ddmenu_case-contacts" do
          click_on case_number
        end
        expect(page).to_not have_text("Case 1 Notes")
        expect(page).to_not have_text("Case 2 Notes")
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
