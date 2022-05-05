require 'spec_helper'

RSpec.describe "External request" do
  it 'queries FactoryBot contributors on GitHub' do
    uri = URI('https://api.github.com/repos/thoughtbot/factory_bot/contributors')

    response = Net::HTTP.get(uri)

    expect(response).to be_an_instance_of(String)
  end
end
