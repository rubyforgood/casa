/* eslint-env jquery */

import Swal from 'sweetalert2'

import { disableBtn, enableBtn } from './casa_case'

const EMAIL_TOGGLE_CLASS = 'toggle-email-notifications'
const SMS_TOGGLE_CLASS = 'toggle-sms-notifications'
const SAVE_BUTTON_CLASS = 'save-preference'
const SMS_NOTIFICATION_EVENT_ID = 'toggle-sms-notification-event'

function displayPopUpIfPreferencesIsInvalid () {
  const emailNotificationState = $('#user_receive_email_notifications').prop('checked')
  const smsNotificationState = $('#user_receive_sms_notifications').prop('checked')

  if (smsNotificationState === false && emailNotificationState === false) {
    disableBtn($(`.${SAVE_BUTTON_CLASS}`)[0])
    Swal.fire({
      icon: 'error',
      title: 'Contact Method Needed',
      text: 'Please select at least one method of contact so we can communicate with you.'
    })
  } else {
    enableBtn($(`.${SAVE_BUTTON_CLASS}`)[0])
  }
}

$(() => { // JQuery's callback for the DOM loading
  const smsToggle = $(`.${SMS_TOGGLE_CLASS}`)[0]
  const emailToggle = $(`.${EMAIL_TOGGLE_CLASS}`)[0]

  emailToggle?.addEventListener('change', () => {
    displayPopUpIfPreferencesIsInvalid()
  })

  smsToggle?.addEventListener('change', () => {
    displayPopUpIfPreferencesIsInvalid()
  })

  const smsEventToggle = $(`#${SMS_NOTIFICATION_EVENT_ID}`)[0]
  if (smsToggle && smsEventToggle) {
    smsEventToggle.disabled = !smsToggle.checked
    smsToggle.addEventListener('change', () => {
      smsEventToggle.disabled = !smsToggle.checked
    })
  }
})

export { displayPopUpIfPreferencesIsInvalid }
