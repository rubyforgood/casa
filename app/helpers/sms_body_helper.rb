module SmsBodyHelper
  def account_activation_msg(resource = "primorgens", hash_of_links = {})
    first_msg = "A CASA #{resource} account was created for you."
    second_msg = " First, set your password here #{hash_of_links[0]}."
    third_msg = " Then visit #{hash_of_links[1]} to change your text message settings."

    if hash_of_links[0] && hash_of_links[1]
      return first_msg + second_msg + third_msg
    elsif hash_of_links[0] == nil && hash_of_links[1]
      return first_msg + " Please check your email to set up your password." + third_msg
    elsif hash_of_links[0] && hash_of_links[1] == nil
      return first_msg + second_msg + " Go to profile edit page to change SMS settings."
    else
      return first_msg + " Please check your email to set up your password. Go to profile edit page to change SMS settings."
    end
  end
end
