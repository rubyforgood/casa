/* eslint-env jquery */
/* global $ */

import Swal from 'sweetalert2'
import { disableBtn, enableBtn } from './casa_case'

const SUBMIT_BUTTON_CLASS = 'submit-password'
const PASSWORD_FIELD_CLASS = 'password-new'
const CONFIRMATION_FIELD_CLASS = 'password-confirmation'

function disableButtonWhenEmptyString (str, button) {
  str.length === 0 ? disableBtn(button) : enableBtn(button)
}

// Checks if the password is equivalent to confirmation and has at least 1 character. If not,
// it will disable the button.
//  @param    {HTMLElement}  button - submit button for the form field
//  @param    {HTMLElement}  password - text input form field
//  @param    {HTMLElement}  confirmation - text input form field
//  @param    {boolean}  enablePopup - display popup when field is not in focus
function checkPasswordsAndDisplayPopup (button, password, confirmation, enablePopup = false) {
  const passwordText = password.value
  const confirmationText = confirmation.value

  if (passwordText === confirmationText) {
    disableButtonWhenEmptyString(passwordText, button)
  } else {
    if (enablePopup) {
      Swal.fire({
        icon: 'error',
        title: 'Password Error',
        text: 'The password and the confirmation password do not match'
      })
    }
    disableBtn(button)
  }
}

// Expects the class name constants above are applied to the correct fields. See
// `app/views/users/edit.html.erb` for usage
$(() => { // JQuery's callback for the DOM loading
  if ($(`.${SUBMIT_BUTTON_CLASS}`).length > 0) {
    const button = $(`.${SUBMIT_BUTTON_CLASS}`)[0]
    const password = $(`.${PASSWORD_FIELD_CLASS}`)[0]
    const confirmation = $(`.${CONFIRMATION_FIELD_CLASS}`)[0]

    disableBtn(button)

    $(`.${PASSWORD_FIELD_CLASS}`).on('blur', () => {
      checkPasswordsAndDisplayPopup(button, password, confirmation)
    })

    $(`.${CONFIRMATION_FIELD_CLASS}`).on('blur', () => {
      checkPasswordsAndDisplayPopup(button, password, confirmation, true)
    })
  }
})

export {
  checkPasswordsAndDisplayPopup
}
