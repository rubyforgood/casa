require "rails_helper"

RSpec.describe UserParameters do
  def build_params(attrs)
    ActionController::Parameters.new(user: attrs)
  end

  describe "#without" do
    it "removes the given keys and is chainable" do
      params = build_params(display_name: "Jane", active: "false", type: "Volunteer")

      result = described_class.new(params).without(:active, :type)

      expect(result).to be_a(described_class)
      expect(result.to_h).to eq("display_name" => "Jane")
    end

    it "removes keys even when the params only has string keys" do
      params = build_params(display_name: "Jane", active: "false")

      result = described_class.new(params).without(:active)

      expect(result.to_h).to eq("display_name" => "Jane")
    end

    it "supports further chaining after without" do
      params = build_params(display_name: "Jane", active: "false", password: "old")

      result = described_class.new(params).without(:active).with_password("new-password")

      expect(result.to_h).to eq("display_name" => "Jane", "password" => "new-password")
    end
  end

  describe "#without_type" do
    it "removes the type key" do
      params = build_params(display_name: "Jane", type: "Volunteer")

      result = described_class.new(params).without_type

      expect(result.to_h).to eq("display_name" => "Jane")
    end
  end

  describe "#without_active" do
    it "removes the active key" do
      params = build_params(display_name: "Jane", active: "false")

      result = described_class.new(params).without_active

      expect(result.to_h).to eq("display_name" => "Jane")
    end
  end

  describe "#with_organization" do
    it "sets casa_org_id" do
      params = build_params(display_name: "Jane")
      organization = create(:casa_org)

      result = described_class.new(params).with_organization(organization)

      expect(result.to_h).to eq("display_name" => "Jane", "casa_org_id" => organization.id)
    end
  end

  describe "#with_password" do
    it "sets password" do
      params = build_params(display_name: "Jane")

      result = described_class.new(params).with_password("secret123")

      expect(result.to_h).to eq("display_name" => "Jane", "password" => "secret123")
    end
  end
end
