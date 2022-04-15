shared_examples_for "shows error for invalid phone numbers" do
  it "shows error message for phone number < 12 digits" do
    role == "admin" || role == "user" ? fill_in("Phone number", with: "+141632489") : fill_in("#{role}_phone_number", with: "+141632489")
    role == "user" ? click_on("Update Profile") : click_on("Submit")
    expect(page).to have_text "Phone number must be 12 digits including country code (+1)"
  end

  it "shows error message for phone number > 12 digits" do
    role == "admin" || role == "user" ? fill_in("Phone number", with: "+141632180923") : fill_in("#{role}_phone_number", with: "+141632180923")
    role == "user" ? click_on("Update Profile") : click_on("Submit")
    expect(page).to have_text "Phone number must be 12 digits including country code (+1)"
  end

  it "shows error message for bad phone number" do
    role == "admin" || role == "user" ? fill_in("Phone number", with: "+141632u809o") : fill_in("#{role}_phone_number", with: "+141632u809o")
    role == "user" ? click_on("Update Profile") : click_on("Submit")
    expect(page).to have_text "Phone number must have correct format"
  end

  it "shows error message for phone number without country code" do
    role == "admin" || role == "user" ? fill_in("Phone number", with: "+24163218092") : fill_in("#{role}_phone_number", with: "+24163218092")
    role == "user" ? click_on("Update Profile") : click_on("Submit")
    expect(page).to have_text "Phone number must have a valid country code (+1)"
  end
end
