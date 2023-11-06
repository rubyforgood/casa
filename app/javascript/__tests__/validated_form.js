/* eslint-env jest */
require('jest')

const { Notifier } = require('../src/notifier.js')
const { NonDrivingContactMediumWarning, RangedDatePicker } = require('../src/validated_form.js')

describe('RangedDatePicker', () => {
  let notifier

  beforeEach(() => {
    document.body.innerHTML =
`<form class="component-validated-form">
  <input
    data-date-format="yyyy/mm/dd"
    data-provide="datepicker"
    data-max-date="today"
    class="component-date-picker-range"
    component-name="occurred on"
    type="text">
</form>

<div id="notifications">
  <div class="messages">
  </div>
  <div id="async-waiting-indicator" style="display: none">
    Saving <i class="load-spinner"></i>
  </div>
  <div id="async-success-indicator" class="success-notification" style="display: none">
    Saved
  </div>
  <button id="toggle-minimize-notifications" style="display: none;">
    <span>minimize notifications </span>
    <span class="badge rounded-pill bg-success" style="display: none;"></span>
    <span class="badge rounded-pill bg-warning" style="display: none;"></span>
    <span class="badge rounded-pill bg-danger" style="display: none;"></span>
    <i class="fa-solid fa-minus"></i>
  </button>
</div>`
    $(() => { // JQuery's callback for the DOM loading
      notifier = new Notifier(notificationsElement)
    })
  })

  describe('constructor', () => {
    test('throws a TypeError when passed an invalid jQuery object', (done) => {
      $(() => {
        try {
          expect(() => {
            // eslint-disable-next-line no-new
            new RangedDatePicker(3, notifier)
          }).toThrow(TypeError)

          done()
        } catch (error) {
          done(error)
        }
      })
    })

    test('throws a RangeError when min date is past max date', (done) => {
      $(() => {
        try {
          const datePickerElement = $('input')
          datePickerElement.attr('data-min-date', new Date(new Date().getTime() + 24 * 60 * 60 * 1000))

          expect(() => {
            // eslint-disable-next-line no-new
            new RangedDatePicker(datePickerElement, notifier)
          }).toThrow(RangeError)

          done()
        } catch (error) {
          done(error)
        }
      })
    })
  })

  describe('errorHighlightUI', () => {

  })

  describe('getErrorState', () => {

  })

  describe('showUserError', () => {

  })

  describe('removeUserError', () => {

  })
})

describe('NonDrivingContactMediumWarning', () => {
  describe('constructor', () => {

  })

  describe('warningHighlightUI', () => {

  })

  describe('showUserWarning', () => {

  })

  describe('removeUserWarning', () => {

  })

  describe('showWarningConfirmation', () => {

  })

  describe('removeWarningConfirmation', () => {

  })
})
