module SmsBodyHelper
  def account_activation_msg(resource = "primorgens", hash_of_links = {})
    password_link = hash_of_links[0]
    edit_link = hash_of_links[1]
    first_msg = "A CASA #{resource} account was created for you."
    second_msg = "First, set your password here #{hash_of_links[0]}."
    third_msg = "Then visit #{hash_of_links[1]} to change your text message settings."
    # default msg
    body_msg = first_msg + " " + "Please check your email to set up your password. Go to profile edit page to change SMS settings."

    if password_link && edit_link
      body_msg = first_msg + " " + second_msg + " " + third_msg
    elsif password_link.nil? && edit_link
      body_msg = first_msg + " " + "Please check your email to set up your password." + " " + third_msg
    elsif hash_of_links[0] && hash_of_links[1].nil?
      body_msg = first_msg + " " + second_msg + " " + "Go to profile edit page to change SMS settings."
    end
    body_msg
  end

  def court_report_due_msg(report_due_date, short_link)
    "Your court report is due on #{report_due_date}. Generate a court report to complete & submit here: #{short_link}"
  end

  def no_contact_made_msg(contact_type, short_link)
    "It's been two weeks since you've tried reaching '#{contact_type}'. Try again! #{short_link}"
  end

  def case_contact_flagged_msg(display_name, short_link)
    "#{display_name} has flagged a Case Contact that needs follow up. Click to see more: #{short_link}"
  end

  def password_reset_msg(display_name, short_link)
    "Hi #{display_name}, click here to reset your password: #{short_link}"
  end
end
