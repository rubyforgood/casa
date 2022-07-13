require "rails_helper"

RSpec.describe "patch_notes/index", type: :view do
  before(:each) do
    assign(:patch_notes, [
      PatchNote.create!,
      PatchNote.create!
    ])
  end

  it "renders a list of patch_notes" do
    render
  end
end
