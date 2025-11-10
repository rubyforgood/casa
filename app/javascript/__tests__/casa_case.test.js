/* eslint-env jest */
/**
 * @jest-environment jsdom
 */

import { showAlert } from '../src/casa_case'

describe('showAlert', () => {
  const defaultErrorMessageHtml = '<div>Error Message</div>'
  const subject = ({
    initialBody = '<div class="header-flash"></div>',
    errorMessageHtml = defaultErrorMessageHtml
  } = {}) => {
    document.body.innerHTML = initialBody
    showAlert(errorMessageHtml)
  }

  test('must render error messages', () => {
    subject()
    expect(document.body.innerHTML).toEqual(defaultErrorMessageHtml)
  })

  describe('when there is no element with header-flash class', () => {
    test('does not render messages', () => {
      const initialBody = '<div></div>'
      subject({ initialBody })
      expect(document.body.innerHTML).toEqual(initialBody)
    })
  })
})
