# frozen_string_literal: true

require "rails_helper"

RSpec.describe Sidebar::AnchorMenuComponent, type: :component do
  before do
    @component = described_class.new(title: "Group Actions", icon: "list")
  end

  it "renders component when rendered links are added" do
    @component.with_link(title: "Generate Court Reports", icon: "paperclip", path: "/case_court_reports")
    @component.with_link(title: "Reimbursement Queue", icon: "money-location", path: "/reimbursements")
    render_inline(@component)

    expect(page).to have_css "li[class='nav-item nav-item-has-children group-item']"
    expect(page).to have_css "a[class='group-actions collapsed']"
    expect(page).to have_css "a[data-bs-target='#ddmenu_group-actions']"
    expect(page).to have_css "a[aria-controls='ddmenu_group-actions']"
    expect(page).to have_css "i[class='lni mr-10 lni-list']"
    expect(page).to have_css "span[data-sidebar-target='linkTitle']", text: "Group Actions"
    expect(page).to have_css "ul[id='ddmenu_group-actions']"
  end

  it "renders links" do
    @component.with_link(title: "Generate Court Reports", icon: "paperclip", path: "/case_court_reports")
    @component.with_link(title: "Reimbursement Queue", icon: "money-location", path: "/reimbursements")
    render_inline(@component)

    expect(page).to have_css "span[data-sidebar-target='linkTitle']", text: "Generate Court Reports"
    expect(page).to have_css "span[data-sidebar-target='linkTitle']", text: "Reimbursement Queue"
  end

  it "does not render component if no links are added" do
    render_inline(@component)

    expect(page).not_to have_css "li[class='nav-item nav-item-has-children group-item']"
  end

  it "does not render component if all links are not rendered" do
    @component.with_link(title: "Generate Court Reports", icon: "paperclip", path: "/case_court_reports", render_check: false)
    render_inline(@component)
  end
end
