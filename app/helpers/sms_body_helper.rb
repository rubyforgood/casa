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
end
