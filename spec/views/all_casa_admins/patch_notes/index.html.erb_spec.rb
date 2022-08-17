require "rails_helper"

RSpec.describe "patch_notes/index", type: :view do
  let(:all_casa_admin) { build(:all_casa_admin) }
  let!(:patch_notes) {
    [
      create(:patch_note),
      create(:patch_note)
    ]
  }

  before(:each) do
    assign(:patch_notes, patch_notes)

    sign_in all_casa_admin
  end

  it "renders a list of patch_notes" do
    render template: "all_casa_admins/patch_notes/index"
  end

  describe "the new patch note form" do
    it "is present on the page" do
      render template: "all_casa_admins/patch_notes/index"

      parsed_html = Nokogiri.HTML5(rendered)

      expect(parsed_html.css("#new-patch-note").length).to eq(1)
    end

    it "contains a button to submit the form" do
      render template: "all_casa_admins/patch_notes/index"

      parsed_html = Nokogiri.HTML5(rendered)

      expect(parsed_html.css("#new-patch-note button").length).to eq(1)
    end

    it "contains a textarea to enter the patch note" do
      render template: "all_casa_admins/patch_notes/index"

      parsed_html = Nokogiri.HTML5(rendered)

      expect(parsed_html.css("#new-patch-note textarea").length).to eq(1)
    end

    it "contains a dropdown for the patch note type" do
      render template: "all_casa_admins/patch_notes/index"

      parsed_html = Nokogiri.HTML5(rendered)

      expect(parsed_html.css("#new-patch-note #new-patch-note-type").length).to eq(1)
    end

    it "contains a dropdown for the patch note group" do
      render template: "all_casa_admins/patch_notes/index"

      parsed_html = Nokogiri.HTML5(rendered)

      expect(parsed_html.css("#new-patch-note #new-patch-note-group").length).to eq(1)
    end
  end
end
