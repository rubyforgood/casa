shared_examples_for "shows past court dates links" do
  let!(:newest_pcd) do
    create(:past_court_date, date: DateTime.current - 5.days, casa_case: casa_case)
  end

  let!(:oldest_pcd) do
    create(:past_court_date, date: DateTime.current - 10.days, casa_case: casa_case)
  end

  let(:past_court_date_with_details) do
    create(:past_court_date, :with_court_details, casa_case: casa_case)
  end

  let(:past_court_date_without_details) do
    create(:past_court_date, casa_case: casa_case)
  end

  let!(:formatted_date_with_details) { I18n.l(past_court_date_with_details.date, format: :full, default: nil) }
  let!(:formatted_date_without_details) { I18n.l(past_court_date_without_details.date, format: :full, default: nil) }

  it "shows court orders" do
    visit edit_casa_case_path(casa_case)

    expect(page).to have_text(formatted_date_with_details)
    expect(page).to have_link(formatted_date_with_details)

    expect(page).to have_text(formatted_date_without_details)
    expect(page).to have_link(formatted_date_without_details)
  end

  it "past court dates are ordered" do
    visit casa_case_path(casa_case)

    expect(page).to have_text((DateTime.current - 10.days).strftime("%B %-d, %Y").to_s)
    expect(page.body).to match /#{oldest_pcd.date.strftime('%B %-d, %Y')}.*#{newest_pcd.date.strftime('%B %-d, %Y')}/m
  end
end
