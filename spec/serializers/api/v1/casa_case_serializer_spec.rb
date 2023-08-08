require "rails_helper"

RSpec.describe Api::V1::CasaCaseSerializer, type: :serializer do
  before(:each) do
    @casa_case = create(:casa_case)
    @serializer = Api::V1::CasaCaseSerializer.new(@casa_case)
    @serialization = ActiveModelSerializers::Adapter.create(@serializer)
  end

  subject { JSON.parse(@serialization.to_json) }

  it "should have matching attributes" do
    # match some attributes returned by serializer
    expect(subject["id"]).to eq(@casa_case.id)
    expect(subject["case_number"]).to eq(@casa_case.case_number)
    expect(subject["birthday"]).to eq(@casa_case.birth_month_year_youth.strftime("%Y-%m-%d"))
    expect(subject["casa_org_id"]).to eq(@casa_case.casa_org_id)
    expect(subject.length).to eq(7)
  end
end
