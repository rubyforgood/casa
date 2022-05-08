/* eslint-env jquery */

import Swal from 'sweetalert2'

import { disableBtn, enableBtn } from './casa_case'

const EMAIL_TOGGLE_CLASS = 'toggle-email-notifications'
const SMS_TOGGLE_CLASS = 'toggle-sms-notifications'
const SAVE_BUTTON_CLASS = 'save-preference'

function displayPopUpIfPreferencesIsInvalid (receiveSms = false, receiveEmail = true) {
    let emailNotificationState = $("#user_receive_email_notifications").prop('checked')
    let smsNotificationState = $("#user_receive_sms_notifications").prop('checked')

    if (smsNotificationState == false && emailNotificationState == false) {
        
        Swal.fire({
            icon: 'error',
            title: 'Preference Error',
            text: 'At least one communication preference required'
          })
    } 

}