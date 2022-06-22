module SmsBodyHelper
  def account_activation_msg(resource = "primorgens", base_url = "hello kitty")
    "A CASA #{resource} account was created for you.
      Visit #{base_url + "/users/edit"} to change text messaging settings."
  end
end
