/* eslint-env jquery */
/* global $ */

import Swal from 'sweetalert2'
import { disableBtn, enableBtn } from './casa_case'

const SUBMIT_EMAIL_BUTTON_CLASS = 'submit-email'
const EMAIL_FIELD_CLASS = 'email-new'
const EMAIL_CONFIRMATION_FIELD_CLASS = 'email-confirmation'

function disableButtonWhenEmptyString(str, button) {
    str.length === 0 ? disableBtn(button) : enableBtn(button)
}

// Checks if the password is equivalent to confirmation and has at least 1 character. If not,
// it will disable the button.
//  @param    {HTMLElement}  button - submit button for the form field
//  @param    {HTMLElement}  password - text input form field
//  @param    {HTMLElement}  confirmation - text input form field
//  @param    {boolean}  enablePopup - display popup when field is not in focus
function checkEmailsAndDisplayPopup(button, email, emailConfirmation, enablePopup = false) {
    const emailText = email.value
    const emailConfirmationText = emailConfirmation.value

    if (emailText === emailConfirmationText) {
        disableButtonWhenEmptyString(emailConfirmation, button)
    } else {
        if (enablePopup) {
            Swal.fire({
                icon: 'error',
                title: 'Email Error',
                text: 'The email and the confirmation email do not match'
            })
        }
        disableBtn(button)
    }
}

// Expects the class name constants above are applied to the correct fields. See
// `app/views/users/edit.html.erb` for usage
$('document').ready(() => {
    if ($(`.${SUBMIT_EMAIL_BUTTON_CLASS}`).length > 0) {
        const button = $(`.${SUBMIT_EMAIL_BUTTON_CLASS}`)[0]
        const email = $(`.${EMAIL_FIELD_CLASS}`)[0]
        const emailConfirmation = $(`.${EMAIL_CONFIRMATION_FIELD_CLASS}`)[0]

        disableBtn(button)

        $(`.${EMAIL_FIELD_CLASS}`).on('blur', () => {
            checkEmailsAndDisplayPopup(button, email, emailConfirmation)
        })

        $(`.${EMAIL_CONFIRMATION_FIELD_CLASS}`).on('blur', () => {
            checkEmailsAndDisplayPopup(button, email, emailConfirmation, true)
        })
    }
})

export {
    checkEmailsAndDisplayPopup
}