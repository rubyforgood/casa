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

$('document').ready(() => {
    $('.password-confirmation').on('blur', () => {
      const button = document.getElementsByClassName("submit-password")[0]
      const password = document.getElementsByClassName("password-new")
      const confirmation = document.getElementsByClassName("password-confirmation")
      const passwordText = password[0].value
      const confirmationText = confirmation[0].value

      if (passwordText === confirmationText){
        enableBtn(button)
      }else{
        disableBtn(button)
      }
    })
})
