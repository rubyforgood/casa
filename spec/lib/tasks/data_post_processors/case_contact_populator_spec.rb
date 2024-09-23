require "rails_helper"
require "./lib/tasks/data_post_processors/case_contact_populator"

RSpec.describe CaseContactPopulator do
  before do
    Rake::Task.clear
    Casa::Application.load_tasks
  end

  it "does nothing on an empty database" do
    described_class.populate

    expect(ContactType.count).to eq(0)
    expect(ContactTypeGroup.count).to eq(0)
  end

  it "does nothing if there are no contact types" do
    case_contact = create(:case_contact, contact_types: [], status: 'started')

    described_class.populate

    expect(case_contact.contact_types).to be_empty
    expect(ContactType.count).to eq(0)
    expect(ContactTypeGroup.count).to eq(0)
  end

  it "creates a new contact type group with the org of the casa case" do
    contact_type = create(:contact_type)
    casa_org1 = contact_type.contact_type_group.casa_org

    casa_org2 = create(:casa_org)
    casa_case = create(:casa_case, casa_org: casa_org2)
    create(:case_contact, casa_case: casa_case, contact_types: [contact_type])

    described_class.populate

    expect(ContactTypeGroup.count).to eq(2)
    expect(ContactTypeGroup.last.casa_org).to eq(casa_org2)

    expect(ContactType.count).to eq(1)
    expect(ContactType.first.contact_type_group.casa_org).to eq(casa_org1)
  end

  it "creates a new contact type with the org of the casa case" do
    ctg1 = create(:contact_type_group, casa_org: create(:casa_org), name: "Education")
    ctg2 = create(:contact_type_group, casa_org: create(:casa_org), name: "Education")

    contact_type = create(:contact_type, contact_type_group: ctg1, name: "School")

    casa_case = create(:casa_case, casa_org: ctg2.casa_org)
    create(:case_contact, casa_case: casa_case, contact_types: [contact_type])

    described_class.populate

    expect(ContactTypeGroup.count).to eq(2)
    expect(ContactType.count).to eq(2)

    expect(ContactType.first.contact_type_group).to eq(ctg1)
    expect(ContactType.last.contact_type_group).to eq(ctg2)
    expect(contact_type.reload.contact_type_group).to eq(ctg1)
  end
end
