require "rails_helper"

describe SidebarHelper do
  describe "#menu_item" do
    it "renders sidebar menu item label correctly" do
      path = "/supervisors"

      menu_item = helper.menu_item(label: "Supervisors", path: path, visible: true)

      expect(menu_item).to match ">Supervisors</a>"
    end

    it "renders sidebar menu item without active link class" do
      path = "/supervisors"

      allow(helper).to receive(:current_page?).with(path).and_return(false)

      menu_item = helper.menu_item(label: "Supervisors", path: path, visible: true)

      expect(menu_item).to match "class=\"list-group-item \""
    end

    it "renders sidebar menu item with active link class" do
      path = "/supervisors"

      allow(helper).to receive(:current_page?).with(path).and_return(true)

      menu_item = helper.menu_item(label: "Supervisors", path: path, visible: true)

      expect(menu_item).to match "class=\"list-group-item active\""
    end

    it "does not render sidebar menu item when not visible" do
      path = "/supervisors"

      menu_item = helper.menu_item(label: "Supervisors", path: path, visible: false)

      expect(menu_item).to be nil
    end
  end
end
