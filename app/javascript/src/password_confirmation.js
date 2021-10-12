function addConfirmationEventListeners() {
  const password = document.getElementsByClassName("password-new")
  const confirmation = document.getElementsByClassName("password-confirmation")

  if(confirmation.length === 0 || password.length === 0){
    console.error("Unable to find password confirmation field", { confirmation })
  }else{
    document.addEventListener("keyUp", function(){
      checkConfirmationEqual(password, confirmation)
    })
  }
}

function checkConfirmationEqual(password, confirmation){
  const passwordText = password[0].value
  const confirmationText = confirmation[0].value
  if (passwordText === confirmationText){
    console.log("EQUAL")
  }else{
    console.log("UNEQUAL")
  }
}
