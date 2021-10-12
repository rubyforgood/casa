const button = document.getElementsByClassName("submit-password")[0]

function disableBtn (el) {
  el.disabled = true
  el.classList.add('disabled')
  el.setAttribute('aria-disabled', true)
}

function enableBtn (el) {
  el.disabled = false
  el.classList.remove('disabled')
  el.removeAttribute('aria-disabled')
}

function addConfirmationEventListeners() {
  const password = document.getElementsByClassName("password-new")
  const confirmation = document.getElementsByClassName("password-confirmation")

  disableBtn(button)

  if(confirmation.length === 0 || password.length === 0){
    console.error("Unable to find password confirmation field", { confirmation })
  }else{
    confirmation[0].addEventListener("keyup", function(){
      checkConfirmationEqual(password, confirmation)
    })
  }
}

function checkConfirmationEqual(password, confirmation){
  const passwordText = password[0].value
  const confirmationText = confirmation[0].value
  if (passwordText === confirmationText){
    enableBtn(button)
  }else{
    disableBtn(button)
  }
}