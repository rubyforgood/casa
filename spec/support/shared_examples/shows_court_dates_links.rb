shared_examples_for "shows court dates links" do
  before do
    travel_to Date.new(2020, 1, 2)
    _newest_pcd = create(:court_date, date: DateTime.current - 5.days, casa_case: casa_case)
    _oldest_pcd = create(:court_date, date: DateTime.current - 10.days, casa_case: casa_case)
    hearing_type = create(:hearing_type, name: "Some Hearing Name")
    _court_date_with_details = create(:court_date, :with_court_details, casa_case: casa_case, hearing_type: hearing_type)
  end
  after { travel_back }

  it "shows court orders" do
    visit edit_casa_case_path(casa_case)
    expect(page).to have_link("December 23, 2019")
    expect(page).to have_link("December 26, 2019")
    expect(page).to have_link("December 26, 2019 - Some Hearing Name")
  end

  it "past court dates are ordered" do
    visit casa_case_path(casa_case)
    expect(page).to have_text("December 23, 2019")
    expect(page).to have_text(/December 23, 2019.*December 28, 2019/m)
  end
end
