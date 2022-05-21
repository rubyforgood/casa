/* eslint-env jquery */

import Swal from 'sweetalert2'

import { disableBtn, enableBtn } from './casa_case'

const EMAIL_TOGGLE_CLASS = 'toggle-email-notifications'
const SMS_TOGGLE_CLASS = 'toggle-sms-notifications'
const SAVE_BUTTON_CLASS = 'save-preference'
const SMS_NOTIFICATION_EVENT_ID = 'toggle-sms-notification-event'

function displayPopUpIfPreferencesIsInvalid (receiveEmail, receiveSMS, triggerPopup = false) {
  const emailNotificationState = $('#user_receive_email_notifications').prop('checked')
  const smsNotificationState = $('#user_receive_sms_notifications').prop('checked')
  receiveSMS = smsNotificationState
  receiveEmail = emailNotificationState

  if (receiveSMS === false && receiveEmail === false) {
    disableBtn($(`.${SAVE_BUTTON_CLASS}`)[0])
    if (triggerPopup) {
      Swal.fire({
        icon: 'error',
        title: 'Preference Error',
        text: 'At least one communication preference required'
      })
    }
  } else {
    enableBtn($(`.${SAVE_BUTTON_CLASS}`)[0])
  }
}

$('document').ready(() => {
  if ($(`.${SAVE_BUTTON_CLASS}`).length > 0) {
    const receiveSMS = $(`.${SMS_TOGGLE_CLASS}`)[0]
    const receiveEmail = $(`.${EMAIL_TOGGLE_CLASS}`)[0]
    enableBtn($(`.${SAVE_BUTTON_CLASS}`)[0])
    $(`.${SMS_TOGGLE_CLASS}`).on('blur', () => {
      displayPopUpIfPreferencesIsInvalid(receiveEmail, receiveSMS, true)
    })

    $(`.${EMAIL_TOGGLE_CLASS}`).on('blur', () => {
      displayPopUpIfPreferencesIsInvalid(receiveEmail, receiveSMS, true)
    })
  }

  const smsToggle = $(`.${SMS_TOGGLE_CLASS}`)[0]
  const smsEventToggle = $(`#${SMS_NOTIFICATION_EVENT_ID}`)[0]
  if(smsToggle && smsEventToggle){
    smsEventToggle.disabled = !smsToggle.checked
    smsToggle.addEventListener('change', () => {
      smsEventToggle.disabled = !smsToggle.checked
    })
  }
})

export { displayPopUpIfPreferencesIsInvalid }
