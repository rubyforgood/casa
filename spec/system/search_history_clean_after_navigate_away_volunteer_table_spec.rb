require "rails_helper"

RSpec.describe "Search history should clean after I navigate away from volunteers view", type: :system do
  let (:supervisor) { create(:supervisor, :with_volunteers)}
  let (:input_field ) { "div#volunteers_filter input" }

  it do
    sign_in supervisor 
    visit volunteers_path
    
    page.find(input_field).set('Test')

    visit supervisors_path
    visit volunteers_path
    input_search = page.find(input_field)
    expect(input_search.value).to eq('')
  end
end
