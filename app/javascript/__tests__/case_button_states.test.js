/* eslint-env jest */
/**
 * @jest-environment jsdom
 */

import {
  disableBtn,
  enableBtn
} from '../src/casa_case'

let button

beforeEach(() => {
  document.body.innerHTML =
    '<button id="test-button">Disable Reports</button>'
  button = document.getElementById('test-button')
})

// showBtn/hideBtn are gone with the legacy court-report code: they toggled Bootstrap's `d-none`,
// which the design system does not define, and once that code went this test was their only caller.
describe('casa_case button helpers apply the correct classes and attributes', () => {
  test('disable button', () => {
    disableBtn(button)
    expect(button.classList.contains('disabled')).toBe(true)
    expect(button.hasAttribute('aria-disabled')).toBe(true)
    expect(button.disabled).toBe(true)
  })

  test('enable button', () => {
    button.disabled = true
    button.classList.add('disabled')
    button.setAttribute('aria-disabled', true)
    enableBtn(button)
    expect(button.classList.contains('disabled')).toBe(false)
    expect(button.hasAttribute('aria-disabled')).toBe(false)
    expect(button.disabled).toBe(false)
  })
})
