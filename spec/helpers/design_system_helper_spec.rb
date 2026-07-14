require "rails_helper"

RSpec.describe DesignSystemHelper, type: :helper do
  describe "#button_classes" do
    it "defaults to the primary variant" do
      expect(helper.button_classes).to eq(helper.button_classes(:primary))
    end

    it "gives every variant the same fixed height token so they cannot drift" do
      %i[primary secondary danger].each do |variant|
        expect(helper.button_classes(variant)).to include("h-10")
      end
    end

    it "styles the primary variant as a filled brand button" do
      expect(helper.button_classes(:primary)).to include("bg-brand-600", "text-white")
    end

    it "styles the secondary variant as an outlined button" do
      classes = helper.button_classes(:secondary)
      expect(classes).to include("border", "border-slate-200", "bg-white", "text-slate-700")
    end

    it "styles the danger variant as a filled rose button" do
      expect(helper.button_classes(:danger)).to include("bg-rose-600", "text-white")
    end

    it "does not compensate the filled variants with a transparent border" do
      # The height token equalizes sizes; a transparent-border hack would be fragile.
      expect(helper.button_classes(:primary)).not_to include("border-transparent")
      expect(helper.button_classes(:danger)).not_to include("border-transparent")
    end

    it "raises for an unknown variant" do
      expect { helper.button_classes(:bogus) }.to raise_error(ArgumentError, /unknown button variant/)
    end
  end
end
