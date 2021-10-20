/* eslint-env jest */

import {
  showBtn,
  hideBtn,
  disableBtn,
  enableBtn
} from '../src/casa_case'

require('jest')

let button

beforeEach(() => {
  document.body.innerHTML =
    '<button id="test-button">Disable Reports</button>'
  button = document.getElementById('test-button')
})

describe('casa_case generate report button applies correct classes and attributes', () => {
  test('show button', () => {
    $(document).ready(() => {
      button.classList.add('d-none')
      showBtn(button)
      expect($(button).is(':visible')).toBe(true)
    })
  })

  test('hide button', () => {
    $(document).ready(() => {
      hideBtn(button)
      expect($(button).is(':visible')).toBe(false)
    })
  })

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
