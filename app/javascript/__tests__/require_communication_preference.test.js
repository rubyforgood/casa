/* eslint-env jest */
import { displayPopUpIfPreferencesIsInvalid } from '../src/require_communication_preference'

require('jest')

let saveButton

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
})
