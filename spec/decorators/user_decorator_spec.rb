require "rails_helper"

RSpec.describe UserDecorator do
  describe "#status" do
    context "when user role is inactive" do
      it "returns Inactive" do
        volunteer = build(:volunteer, :inactive)

        expect(volunteer.decorate.status).to eq "Inactive"
      end
    end

    context "when user role is volunteer" do
      it "returns Active" do
        volunteer = build(:volunteer)

        expect(volunteer.decorate.status).to eq "Active"
      end
    end
  end
end
