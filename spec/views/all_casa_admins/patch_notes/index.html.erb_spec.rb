require "rails_helper"

RSpec.describe "patch_notes/index", type: :view do
  let(:all_casa_admin) { build(:all_casa_admin) }
  let!(:patch_notes) {
    [
      create(:patch_note),
      create(:patch_note)
    ]
  }

  before do
    assign(:patch_notes, patch_notes)
    assign(:patch_note_groups, PatchNoteGroup.all)
    assign(:patch_note_types, PatchNoteType.all)

    sign_in all_casa_admin
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

    it "contains a dropdown for the patch note group" do
      render template: "all_casa_admins/patch_notes/index"

      parsed_html = Nokogiri.HTML5(rendered)

      expect(parsed_html.css("#new-patch-note #new-patch-note-group").length).to eq(1)
    end

    it "contains a dropdown for the patch note type" do
      render template: "all_casa_admins/patch_notes/index"

      parsed_html = Nokogiri.HTML5(rendered)

      expect(parsed_html.css("#new-patch-note #new-patch-note-type").length).to eq(1)
    end

    it "contains a textarea to enter the patch note" do
      render template: "all_casa_admins/patch_notes/index"

      parsed_html = Nokogiri.HTML5(rendered)

      expect(parsed_html.css("#new-patch-note textarea").length).to eq(1)
    end

    describe "the patch note group dropdown" do
      let!(:patch_note_group_1) { create(:patch_note_group, value: "8Sm02WT!zZnJ") }

      it "contains all the patch note group values as options" do
        render template: "all_casa_admins/patch_notes/index"

        parsed_html = Nokogiri.HTML5(rendered)

        option_text = parsed_html.css("#new-patch-note #new-patch-note-group option").text

        expect(option_text).to include(patch_note_group_1.value)
      end
    end

    describe "the patch note type dropdown" do
      let!(:patch_note_type_1) { create(:patch_note_type, name: "3dI!9a9@s$KX") }

      it "contains all the patch note type values as options" do
        render template: "all_casa_admins/patch_notes/index"

        parsed_html = Nokogiri.HTML5(rendered)

        option_text = parsed_html.css("#new-patch-note #new-patch-note-type option").text

        expect(option_text).to include(patch_note_type_1.name)
      end
    end
  end

  describe "the patch note list" do
    it "displays the patch_notes" do
      patch_notes[0].update(note: "?UvV*Z~v\"`P]4ol")
      patch_notes[1].update(note: "#tjJ/+o\"3s@osjV")

      render template: "all_casa_admins/patch_notes/index"
      parsed_html = Nokogiri.HTML5(rendered)

      expect(parsed_html.css(".patch-note-list-item textarea").text).to include(patch_notes[0].note)
      expect(parsed_html.css(".patch-note-list-item textarea").text).to include(patch_notes[1].note)
    end

    it "displays the latest patch notes first" do
      patch_notes[0].update(note: "#'hQ+`dGC(qc=}wu")
      patch_notes[1].update(note: "k2cz&c'xYLr|&)B)")

      render template: "all_casa_admins/patch_notes/index"
      parsed_html = Nokogiri.HTML5(rendered)

      expect(parsed_html.css(".patch-note-list-item textarea")[1].text).to include(patch_notes[0].note)
      expect(parsed_html.css(".patch-note-list-item textarea")[2].text).to include(patch_notes[1].note)
      expect(patch_notes[0].created_at < patch_notes[1].created_at).to eq(true)
    end

    it "displays the correct patch note group and patch note type with the patch note" do
      patch_notes[0].update(note: "#'hQ+`dGC(qc=}wu")
      patch_notes[1].update(note: "k2cz&c'xYLr|&)B)")

      render template: "all_casa_admins/patch_notes/index"
      parsed_html = Nokogiri.HTML5(rendered)

      patch_note_element = parsed_html.css(".patch-note-list-item")[1]

      expect(patch_note_element.css("textarea").text).to include(patch_notes[0].note)
      expect(patch_note_element
        .css("#patch-note-#{patch_notes[0].id}-group option[@selected=\"selected\"]")
        .attr("value").value).to eq(patch_notes[0].patch_note_group_id.to_s)
      expect(patch_note_element
        .css("#patch-note-#{patch_notes[0].id}-type option[@selected=\"selected\"]")
        .attr("value").value).to eq(patch_notes[0].patch_note_type_id.to_s)
    end
  end
end
