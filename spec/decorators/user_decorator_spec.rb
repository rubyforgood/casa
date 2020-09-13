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

  describe "#name" do
    context "when user has a name" do
      it "returns the name" do
        user = build(:user, display_name: "User Name")

        expect(user.decorate.name).to eq user.display_name
      end
    end

    # context "when user has no name" do
    #   it "returns the email" do
    #     user = build(:user)

    #     expect(user.decorate.name).to eq user.email
    #   end
    # end
  end
end
