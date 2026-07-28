require "rails_helper"

RSpec.describe BaseNotifier, type: :model do
  # BaseNotifier is a concrete Noticed::Event subclass (not abstract in the Ruby
  # sense) - `.new`/`.with` both work directly, they just raise on the
  # unimplemented template methods below.

  describe "title" do
    it "raises NotImplementedError" do
      # NOTE: the source string is missing its closing quote:
      # "...has not implemented method '#{__method__}" - characterizing as-is.
      expect { described_class.new.title }.to raise_error(
        NotImplementedError, "BaseNotifier has not implemented method 'title"
      )
    end
  end

  describe "message" do
    it "raises NotImplementedError" do
      expect { described_class.new.message }.to raise_error(
        NotImplementedError, "BaseNotifier has not implemented method 'message"
      )
    end
  end

  describe "url" do
    it "raises NotImplementedError" do
      expect { described_class.new.url }.to raise_error(
        NotImplementedError, "BaseNotifier has not implemented method 'url"
      )
    end
  end

  describe "read?" do
    it "delegates to record.read?" do
      # record is just a plain AR association target here (User has no
      # read? of its own), so a singleton method stands in for a
      # verified double.
      record = create(:user)
      def record.read?
        true
      end

      notifier = described_class.with(record: record)

      expect(notifier.read?).to be true
    end
  end

  describe "created_at" do
    it "delegates to record.created_at" do
      record = create(:user)

      notifier = described_class.with(record: record)

      expect(notifier.created_at).to eq record.created_at
    end
  end

  describe "updated_at" do
    it "delegates to record.updated_at" do
      record = create(:user)

      notifier = described_class.with(record: record)

      expect(notifier.updated_at).to eq record.updated_at
    end
  end

  describe "created_by" do
    context "when params includes :created_by" do
      it "returns the display_name of the created_by param" do
        user = create(:user, display_name: "Jane Doe")

        notifier = described_class.with(created_by: user)

        expect(notifier.created_by).to eq "Jane Doe"
      end
    end

    context "when params does not include :created_by" do
      it "falls back to the legacy created_by_name param for backward compatibility" do
        notifier = described_class.with(created_by_name: "Legacy Name")

        expect(notifier.created_by).to eq "Legacy Name"
      end
    end
  end
end
