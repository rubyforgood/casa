require "rails_helper"

RSpec.describe ContactTopicAnswer do
  specify do
    expect(subject).to belong_to(:case_contact)
    expect(subject).to belong_to(:contact_topic).optional(true)
    expect(subject).to have_one(:contact_creator).through(:case_contact)
    expect(subject).to have_one(:contact_creator_casa_org).through(:contact_creator)
    expect(subject).to have_db_column(:value).of_type(:text).with_options(limit: nil)
  end
end
