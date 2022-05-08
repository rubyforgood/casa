/* eslint-env jquery */

import Swal from 'sweetalert2'

import { disableBtn, enableBtn } from './casa_case'

const EMAIL_TOGGLE_CLASS = 'toggle-email-notifications'
const SMS_TOGGLE_CLASS = 'toggle-sms-notifications'
const SAVE_BUTTON_CLASS = 'save-preference'

function displayPopUpIfPreferencesIsInvalid () {
    let emailNotificationState = $("#user_receive_email_notifications").prop('checked')
    let smsNotificationState = $("#user_receive_sms_notifications").prop('checked')

    if (smsNotificationState == false && emailNotificationState == false) {
        disableBtn($(`.${SAVE_BUTTON_CLASS}`)[0])
        Swal.fire({
            icon: 'error',
            title: 'Preference Error',
            text: 'At least one communication preference required'
          })
    } else {
        enableBtn($(`.${SAVE_BUTTON_CLASS}`)[0])
    }
}

$('document').ready(() => {
    if ($(`.${SAVE_BUTTON_CLASS}`).length > 0) {
        enableBtn($(`.${SUBMIT_BUTTON_CLASS}`)[0])
        $(`.${SMS_TOGGLE_CLASS}`).on('blur', () => {
            displayPopUpIfPreferencesIsInvalid() 
        })
    
        $(`.${EMAIL_TOGGLE_CLASS}`).on('blur', () => {
            displayPopUpIfPreferencesIsInvalid() 
        })
      }
    })