/* eslint-env jest */
/**
 * @jest-environment jsdom
 */

import { displayPopUpIfPreferencesIsInvalid } from '../src/require_communication_preference'

let saveButton
let emailCheckbox
let smsCheckbox

beforeEach(() => {
  document.body.innerHTML = `
 <form action="." method="post" class="test-form">
   <div>
       <input class="toggle-email-notifications" type="checkbox" value="1" checked="checked" name="user[receive_email_notifications]" id="user_receive_email_notifications">
       <label for="user_receive_email_notifications">Email Me</label>
   </div>

   <div>
       <input class="toggle-sms-notifications" type="checkbox" value="1" name="user[receive_sms_notifications]" id="user_receive_sms_notifications">
       <label for="user_receive_sms_notifications">Text Me</label>

       <div class="action_container">
           <input type="submit" name="commit" value="Save Preferences" class="btn btn-primary mb-3 save-preference" data-disable-with="Save Preferences">
       </div>
 </form>
 `
  saveButton = document.getElementsByClassName('save-preference')[0]
  emailCheckbox = document.getElementById('user_receive_email_notifications')
  smsCheckbox = document.getElementById('user_receive_sms_notifications')
})

describe('ensure the save button is enabled when at least one preference is selected', () => {
  function isDisabled (el) {
    return el.disabled && el.classList.contains('disabled') && el.hasAttribute('aria-disabled')
  }

  test('default user preferences state is always valid', () => {
    displayPopUpIfPreferencesIsInvalid()
    expect(isDisabled(saveButton)).toBe(false)
    expect(document.getElementsByClassName('swal2-container').length).toBe(0)
  })

  test('at least email preference is selected', () => {
    emailCheckbox.checked = true
    smsCheckbox.checked = false
    displayPopUpIfPreferencesIsInvalid()
    expect(isDisabled(saveButton)).toBe(false)
    expect(document.getElementsByClassName('swal2-container').length).toBe(0)
  })

  test('at least SMS preference is selected', () => {
    emailCheckbox.checked = false
    smsCheckbox.checked = true
    displayPopUpIfPreferencesIsInvalid()
    expect(isDisabled(saveButton)).toBe(false)
    expect(document.getElementsByClassName('swal2-container').length).toBe(0)
  })

  test('both preferences are selected', () => {
    emailCheckbox.checked = true
    smsCheckbox.checked = true
    displayPopUpIfPreferencesIsInvalid()
    expect(isDisabled(saveButton)).toBe(false)
    expect(document.getElementsByClassName('swal2-container').length).toBe(0)
  })

  test('no preferences selected shows popup', () => {
    emailCheckbox.checked = false
    smsCheckbox.checked = false
    displayPopUpIfPreferencesIsInvalid()
    expect(document.getElementsByClassName('swal2-container').length).toBe(1)
  })
})
