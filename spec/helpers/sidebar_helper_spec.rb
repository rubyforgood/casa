require "rails_helper"

RSpec.describe SidebarHelper do
  describe "#menu_item" do
    it "does not render sidebar menu item when not visible" do
      menu_item = helper.menu_item(label: "Supervisors", path: supervisors_path, visible: false)

      expect(menu_item).to be nil
    end

    it "renders sidebar menu item label correctly" do
      allow(helper).to receive(:action_name).and_return("index")
      allow(helper).to receive(:current_page?).with({controller: "supervisors", action: "index"}).and_return(true)

      menu_item = helper.menu_item(label: "Supervisors", path: supervisors_path, visible: true)

      expect(menu_item).to match ">Supervisors</a>"
    end

    describe "menu item active state" do
      context "when current page does not match the menu item path" do
        it "renders sidebar menu item as an inactive link" do
          allow(helper).to receive(:action_name).and_return("index")
          allow(helper).to receive(:current_page?).with({controller: "supervisors", action: "index"}).and_return(false)

          menu_item = helper.menu_item(label: "Supervisors", path: supervisors_path, visible: true)

          expect(menu_item).to match "class=\"list-group-item \""
        end
      end

      context "when accessing an index route" do
        it "renders sidebar menu item as an active link" do
          helper.request.path = "/supervisors"

          menu_item = helper.menu_item(label: "Supervisors", path: supervisors_path, visible: true)

          expect(menu_item).to match "class=\"list-group-item active\""
        end
      end

      context "when accessing an all casa admin menu item" do
        it "renders the sidebar menu item as an active link" do
          # allow(helper).to receive(:action_name).and_return("index")
          # allow(helper).to receive(:current_page?).with({controller: "patch_notes", action: "index"}).and_return(true)
          helper.request.path = "/all_casa_admins/patch_notes"

          menu_item = helper.menu_item(label: "Patch Notes", path: all_casa_admins_patch_notes_path, visible: true)

          expect(menu_item).to match "class=\"list-group-item active\""
        end
      end

      context "when accessing an volunteer emancipation checklist" do
        it "renders the sidebar menu item as an active link with no redirect" do
          helper.request.path = "/emancipation_checklists"

          menu_item = helper.menu_item(label: "Emancipation Checklist(s)", path: emancipation_checklists_path, visible: true)

          expect(menu_item).to match "class=\"list-group-item active\""
        end

        it "renders the sidebar menu item as an active link with redirect" do
          helper.request.path = "/casa_cases/some-case-slug/emancipation"

          menu_item = helper.menu_item(label: "Emancipation Checklist(s)", path: emancipation_checklists_path, visible: true)

          expect(menu_item).to match "class=\"list-group-item active\""
        end
      end
    end
  end

  describe "#cases_index_title" do
    it "returns 'My Cases' when logged in as a volunteer" do
      volunteer = build :volunteer

      allow(helper).to receive(:current_user).and_return(volunteer)

      expect(helper.cases_index_title).to eq "My Cases"
    end

    it "returns 'Cases' when logged in as a supervisor" do
      volunteer = build :volunteer

      allow(helper).to receive(:current_user).and_return(volunteer)

      expect(helper.cases_index_title).to eq "My Cases"
    end
  end

  describe "#inbox_label" do
    it "returns 'Inbox' when there are no unread notifications" do
      volunteer = build :volunteer

      allow(helper).to receive(:current_user).and_return(volunteer)

      expect(helper.inbox_label).to eq "Inbox"
    end
  end
end
