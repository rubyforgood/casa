/* eslint-env jest */
import { checkPasswordsAndDisplayPopup } from '../src/password_confirmation'

require('jest')

let submitButton, passwordField, confirmationField

beforeEach(() => {
  document.body.innerHTML = `
  <form action="." method="post" class="test-form">
    <div>
      <label for="user_password">New Password</label><br>
      <input autocomplete="off" class="form-control password-new" minlength="6" type="password" name="user[password]" id="user_password" />
    </div>
    <div>
      <label for="user_password_confirmation">New Password Confirmation</label><br>
      <input class="form-control password-confirmation" minlength="6" type="password" name="user[password_confirmation]" id="user_password_confirmation" />
    </div>
    <input type="submit" name="commit" value="Update Password" class="btn btn-danger submit-password" data-disable-with="Update Password" />
  </form>
  `
  submitButton = document.getElementsByClassName('submit-password')[0]
  passwordField = document.getElementsByClassName('password-new')[0]
  confirmationField = document.getElementsByClassName('password-confirmation')[0]

  submitButton.disabled = true
  submitButton.classList.add('disabled')
  submitButton.setAttribute('aria-disabled', true)
})

describe('ensure the password field matches the confirmation field on the client side', () => {
  function isDisabled (el) {
    return el.disabled && el.classList.contains('disabled') && el.hasAttribute('aria-disabled')
  }

  test('password fields match', () => {
    passwordField.value = '12345678'
    confirmationField.value = '12345678'
    checkPasswordsAndDisplayPopup(submitButton, passwordField, confirmationField)
    expect(isDisabled(submitButton)).toBe(false)
    expect(document.getElementsByClassName('swal2-container').length).toBe(0)
  })

  test("password fields don't match", () => {
    passwordField.value = '12345678'
    confirmationField.value = 'bad'
    checkPasswordsAndDisplayPopup(submitButton, passwordField, confirmationField, true)
    expect(document.getElementsByClassName('swal2-container').length).toBe(1)
  })

  test("password fields don't match and pop-up suppressed", () => {
    passwordField.value = '12345678'
    confirmationField.value = 'bad'
    checkPasswordsAndDisplayPopup(submitButton, passwordField, confirmationField)
    expect(document.getElementsByClassName('swal2-container').length).toBe(0)
  })

  test('password fields match but are empty', () => {
    expect(isDisabled(submitButton)).toBe(true)
    expect(document.getElementsByClassName('swal2-container').length).toBe(0)
  })
})
