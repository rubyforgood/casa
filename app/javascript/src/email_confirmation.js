/* eslint-env jquery */
/* global $ */

import Swal from 'sweetalert2'
import { disableBtn, enableBtn } from './casa_case'

const SUBMIT_EMAIL_BUTTON_CLASS = 'submit-email'
const EMAIL_FIELD_CLASS = 'email-new'

function disableButtonWhenEmptyEmailString (str, btn) {
  str.length === 0 ? disableBtn(btn) : enableBtn(btn)
}

// Checks if the password is equivalent to confirmation and has at least 1 character. If not,
// it will disable the button.
//  @param    {HTMLElement}  button - submit button for the form field
//  @param    {HTMLElement}  password - text input form field
//  @param    {HTMLElement}  confirmation - text input form field
//  @param    {boolean}  enablePopup - display popup when field is not in focus
function checkEmailsAndDisplayPopup (btn, email, enableEmailPopup = false) {
  const emailText = email.value

  if (emailText !== ' ' && (/^\w+([.-]?\w+)*@\w+([.-]?\w+)*(\.\w{2,3})+$/.test(emailText))) {
    disableButtonWhenEmptyEmailString(email, btn)
  } else {
    if (enableEmailPopup) {
      Swal.fire({
        icon: 'error',
        title: 'Email Error',
        text: 'Please Enter A Valid Email'
      })
    }
    disableBtn(btn)
  }
}

// Expects the class name constants above are applied to the correct fields. See
// `app/views/users/edit.html.erb` for usage
$('document').ready(() => {
  if ($(`.${SUBMIT_EMAIL_BUTTON_CLASS}`).length > 0) {
    const btn = $(`.${SUBMIT_EMAIL_BUTTON_CLASS}`)[0]
    const email = $(`.${EMAIL_FIELD_CLASS}`)[0]

    disableBtn(btn)

    $(`.${EMAIL_FIELD_CLASS}`).on('blur', () => {
      checkEmailsAndDisplayPopup(btn, email, true)
    })
  }
})

export {
  checkEmailsAndDisplayPopup
}
