require "rails_helper"

RSpec.describe PatchNotePolicy, type: :policy do
  subject { described_class }

  let(:user) { User.new }

  permissions ".scope" do
    pending "add some examples to (or delete) #{__FILE__}"
  end
end
