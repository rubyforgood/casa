require "rails_helper"
require "contact_type_group"

RSpec.describe ContactTypeGroup, type: :model do
  it "should not have duplicate names" do
    name = create(:contact_type_group, {name: "Test1"})

    expect { create(:contact_type_group, {name: "Test1"})}.to raise_error(ActiveRecord::RecordInvalid, "Validation failed: Name has already been taken")
  end
end
