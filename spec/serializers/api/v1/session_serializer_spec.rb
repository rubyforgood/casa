require "rails_helper"

RSpec.describe Api::V1::SessionSerializer, type: :serializer do
  before(:each) do
    @casa_org = create(:casa_org)
    @volunteer = create(:volunteer, casa_org: @casa_org)
    @serializer = Api::V1::SessionSerializer.new(@volunteer)
    @serialization = ActiveModelSerializers::Adapter.create(@serializer)
  end

  subject { JSON.parse(@serialization.to_json) }

  it "should have matching attributes" do
    expect(subject["id"]).to eq(@volunteer.id)
    expect(subject["email"]).to eq(@volunteer.email)
    expect(subject["display_name"]).to eq(@volunteer.display_name)
    expect(subject["token"]).to eq(@volunteer.token)
    expect(subject.length).to eq(4)
  end
end
