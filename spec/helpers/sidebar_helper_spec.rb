require "rails_helper"

describe SidebarHelper do
  describe "#menu_item" do
    it "does not render sidebar menu item when not visible" do
      menu_item = helper.menu_item(label: "Supervisors", path: supervisors_path, visible: false)

      expect(menu_item).to be nil
    end

    it "renders sidebar menu item label correctly" do
      allow(helper).to receive(:action_name).and_return("index")
      allow(helper).to receive(:current_page?).with(controller: "supervisors", action: "index").and_return(true)

      menu_item = helper.menu_item(label: "Supervisors", path: supervisors_path, visible: true)

      expect(menu_item).to match ">Supervisors</a>"
    end

    describe "menu item active state" do
      context "when current page does not match the menu item path" do
        it "renders sidebar menu item as an inactive link" do
          allow(helper).to receive(:action_name).and_return("index")
          allow(helper).to receive(:current_page?).with(controller: "supervisors", action: "index").and_return(false)

          menu_item = helper.menu_item(label: "Supervisors", path: supervisors_path, visible: true)

          expect(menu_item).to match "class=\"list-group-item \""
        end
      end

      context "when accessing an index route" do
        it "renders sidebar menu item as an active link" do
          allow(helper).to receive(:action_name).and_return("index")
          allow(helper).to receive(:current_page?).with(controller: "supervisors", action: "index").and_return(true)

          menu_item = helper.menu_item(label: "Supervisors", path: supervisors_path, visible: true)

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
end
