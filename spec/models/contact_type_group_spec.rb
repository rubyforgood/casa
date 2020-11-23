require "rails_helper"
require "contact_type_group"

RSpec.describe ContactTypeGroup, type: :model do
  it "does not have duplicate names" do
    org_id = create(:casa_org).id
    create_contact_type_group = -> { create(:contact_type_group, {name: "Test1", casa_org_id: org_id}) }
    create_contact_type_group.call
    expect { create_contact_type_group.call }.to raise_error(ActiveRecord::RecordInvalid, "Validation failed: Name has already been taken")
  end
end
