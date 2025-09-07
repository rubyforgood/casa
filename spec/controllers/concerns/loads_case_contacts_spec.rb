require "rails_helper"

RSpec.describe LoadsCaseContacts do
  let(:host) do
    Class.new do
      include LoadsCaseContacts
    end
  end

  it "exists and defines private API" do
    expect(described_class).to be_a(Module)
    expect(host.private_instance_methods)
      .to include(:load_case_contacts, :current_organization_groups, :all_case_contacts)
  end
end
