# frozen_string_literal: true

require "rails_helper"
require "faker"

RSpec.describe "judges/new", type: :system do
  let(:organization) { create(:casa_org) }
  let(:admin) { create(:casa_admin, casa_org_id: organization.id) }
  let(:active_name) { Faker::Name.unique.name }
  let(:inactive_name) { Faker::Name.unique.name }

  before do
    sign_in admin
    visit new_judge_path
  end

  # rubocop:disable RSpec/ExampleLength
  it "creates an active judge with valid name", :aggregate_failures do
    submit_judge_form(name: active_name, active: true)
    expect(page).to have_text("Judge was successfully created.")
    expect(page).to have_text(active_name)

    judge = Judge.find_by(name: active_name)
    expect(judge).not_to be_nil
    expect(judge.active).to be true
  end
  # rubocop:enable RSpec/ExampleLength

  # rubocop:disable RSpec/ExampleLength
  it "creates an inactive judge with valid name", :aggregate_failures do
    submit_judge_form(name: inactive_name, active: false)
    expect(page).to have_text("Judge was successfully created.")
    expect(page).to have_text(inactive_name)

    judge = Judge.find_by(name: inactive_name)
    expect(judge).not_to be_nil
    expect(judge.active).to be false
  end
  # rubocop:enable RSpec/ExampleLength

  # rubocop:disable RSpec/ExampleLength
  it "creates a judge with a very long name", :aggregate_failures do
    long_name = Faker::Lorem.characters(number: 255)
    submit_judge_form(name: long_name)
    expect(page).to have_text("Judge was successfully created.")
    expect(page).to have_text(long_name)

    judge = Judge.find_by(name: long_name)
    expect(judge).not_to be_nil
  end
  # rubocop:enable RSpec/ExampleLength

  # rubocop:disable RSpec/ExampleLength
  it "creates a judge with special characters in the name", :aggregate_failures do
    special_name = "#{Faker::Lorem.characters(number: 30, min_alpha: 10, min_numeric: 5)}!@#$%^&*()"
    submit_judge_form(name: special_name)
    expect(page).to have_text("Judge was successfully created.")
    expect(page).to have_text(special_name)

    judge = Judge.find_by(name: special_name)
    expect(judge).not_to be_nil
  end
  # rubocop:enable RSpec/ExampleLength

  private

  def submit_judge_form(name:, active: true)
    fill_in "Name", with: name
    active ? check("Active?") : uncheck("Active?")
    click_on "Submit"
  end
end
