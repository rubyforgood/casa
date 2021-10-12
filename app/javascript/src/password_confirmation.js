import Swal from 'sweetalert2'

import { disableBtn, enableBtn } from './casa_case'

$('document').ready(() => {
  $('.password-confirmation').on('blur', () => {
    const button = document.getElementsByClassName('submit-password')[0]
    const password = document.getElementsByClassName('password-new')
    const confirmation = document.getElementsByClassName('password-confirmation')
    const passwordText = password[0].value
    const confirmationText = confirmation[0].value

    if (passwordText === confirmationText) {
      enableBtn(button)
    } else {
      Swal.fire({
        icon: 'error',
        title: 'Password Error',
        text: 'The password and the confirmation password do not match'
      })
      disableBtn(button)
    }
  })
})
