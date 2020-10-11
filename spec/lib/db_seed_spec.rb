require "rails_helper"

RSpec.describe "db:seed" do
  before do
    Rake::Task.clear
    Casa::Application.load_tasks
  end

  describe "#development seed file" do
    before do
      load "#{Rails.root}/db/seeds/development.rb"
    end

    it "creates a CasaCase" do
      expect(CasaCase.all.size).to eq(2)
    end

    it "creates a CaseContact" do
      expect(CaseContact.all.size).to eq(1)
    end
  end

  describe "#staging seed file" do
    before do
      load "#{Rails.root}/db/seeds/staging.rb"
    end

    it "creates a CasaCase" do
      expect(CasaCase.all.size).to eq(150)
    end

    it "creates a Volunteer" do
      expect(Volunteer.all.size).to eq(101)
    end

    it "creates a Supervisor" do
      expect(Supervisor.all.size).to eq(6)
    end
  end
end
