/* eslint-env jest */
require('jest')

const { Notifier } = require('../src/notifier.js')
const { NonDrivingContactMediumWarning, RangedDatePicker } = require('../src/validated_form.js')

const MILLISECONDS_IN_A_DAY = 86400000

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
      notifier = new Notifier($('#notifications'))
    })
  })

  describe('constructor', () => {
    test('Throws appropriate errors when initialized with values other than a valid jQuery object', (done) => {
      $(() => {
        try {
          expect(() => {
            // eslint-disable-next-line no-new
            new RangedDatePicker(3, notifier)
          }).toThrow(TypeError)

          expect(() => {
            // eslint-disable-next-line no-new
            new RangedDatePicker($('#non-existant'), notifier)
          }).toThrow(ReferenceError)

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
          datePickerElement.attr('data-min-date', new Date(new Date().getTime() + MILLISECONDS_IN_A_DAY))

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
    let rangedDatePicker
    let datePickerElement

    beforeEach(() => {
      $(() => {
        datePickerElement = $('input')
        rangedDatePicker = new RangedDatePicker($('input'), notifier)
      })
    })

    test('draws a red border around the input if passed an error message', (done) => {
      $(() => {
        try {
          expect(datePickerElement.css('border')).not.toMatch('2px solid red')
          rangedDatePicker.errorHighlightUI('An error')

          expect(datePickerElement.css('border')).toBe('2px solid red')
          done()
        } catch (error) {
          done(error)
        }
      })
    })

    test('removes the red border around the input when passed a falsy value if it was previously highlighted to indicate an error', (done) => {
      $(() => {
        try {
          expect(datePickerElement.css('border')).not.toMatch('solid red')
          rangedDatePicker.errorHighlightUI('An error')

          expect(datePickerElement.css('border')).toBe('2px solid red')

          rangedDatePicker.errorHighlightUI()

          expect(datePickerElement.css('border')).not.toMatch('solid red')
          done()
        } catch (error) {
          done(error)
        }
      })
    })
  })

  describe('getErrorState', () => {
    let rangedDatePicker
    let datePickerElement

    beforeEach(() => {
      $(() => {
        datePickerElement = $('input')
        datePickerElement.attr('data-min-date', new Date(new Date().getTime() - (2 * MILLISECONDS_IN_A_DAY)))
        rangedDatePicker = new RangedDatePicker($('input'), notifier)
      })
    })

    test('returns an error message if the user input date is past max', (done) => {
      $(() => {
        try {
          datePickerElement.val(new Date(new Date().getTime() + MILLISECONDS_IN_A_DAY))

          const errorState = rangedDatePicker.getErrorState()

          expect(typeof errorState).toBe('string')
          expect(errorState.length).toBeGreaterThan(0)
          done()
        } catch (error) {
          done(error)
        }
      })
    })

    test('returns an error message if the user input date is before min', (done) => {
      $(() => {
        try {
          datePickerElement.val(new Date(new Date().getTime() - (3 * MILLISECONDS_IN_A_DAY)))

          const errorState = rangedDatePicker.getErrorState()

          expect(typeof errorState).toBe('string')
          expect(errorState.length).toBeGreaterThan(0)
          done()
        } catch (error) {
          done(error)
        }
      })
    })

    test('returns a falsy value if the user input string is between min and max', (done) => {
      $(() => {
        try {
          datePickerElement.val(new Date(new Date().getTime() - MILLISECONDS_IN_A_DAY))

          const errorState = rangedDatePicker.getErrorState()

          expect(errorState).toBeFalsy()
          done()
        } catch (error) {
          done(error)
        }
      })
    })
  })

  describe('showUserError', () => {
    let rangedDatePicker
    let notifierElement

    beforeEach(() => {
      $(() => {
        notifierElement = $('#notifications')
        rangedDatePicker = new RangedDatePicker($('input'), notifier)
      })
    })

    test('shows an error notification to the user', (done) => {
      $(() => {
        try {
          const errorText = 'Q~Au\\`FMET"["8.JKB_M'

          rangedDatePicker.showUserError(errorText)

          const notifications = notifierElement.find('.danger-notification')
          expect(notifications[0].innerHTML).toContain(errorText)
          done()
        } catch (error) {
          done(error)
        }
      })
    })

    test('changes the text of the error notification if it already exists', (done) => {
      $(() => {
        try {
          const errorText = 'Q~Au\\`FMET"["8.JKB_M'
          const errorText2 = 'l6o4H/z*KnA:/AFg.-.G'

          rangedDatePicker.showUserError(errorText)

          const notifications = notifierElement.find('.danger-notification')
          expect(notifications[0].innerHTML).toContain(errorText)

          rangedDatePicker.showUserError(errorText2)

          expect(notifierElement[0].innerHTML).not.toContain(errorText)
          expect(notifications[0].innerHTML).toContain(errorText2)
          done()
        } catch (error) {
          done(error)
        }
      })
    })
  })

  describe('removeUserError', () => {
    let rangedDatePicker
    let notifierElement

    beforeEach(() => {
      $(() => {
        notifierElement = $('#notifications')
        rangedDatePicker = new RangedDatePicker($('input'), notifier)
      })
    })

    test('removes the error notification shown to the user', (done) => {
      $(() => {
        try {
          const errorText = 'Q~Au\\`FMET"["8.JKB_M'

          rangedDatePicker.showUserError(errorText)

          const notifications = notifierElement.find('.danger-notification')
          expect(notifications[0].innerHTML).toContain(errorText)

          rangedDatePicker.removeUserError()

          expect(notifierElement.find('.danger-notification').length).toBe(0)
          expect(notifierElement[0].innerHTML).not.toContain(errorText)
          done()
        } catch (error) {
          done(error)
        }
      })
    })
  })
})

describe('NonDrivingContactMediumWarning', () => {
  let notifier

  beforeEach(() => {
    document.body.innerHTML =
`<form class="component-validated-form">
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
      notifier = new Notifier($('#notifications'))
    })
  })

  describe('constructor', () => {
    test('Throws appropriate errors when initialized with values other than a valid jQuery object', (done) => {
      $(() => {
        try {
          expect(() => {
            // eslint-disable-next-line no-new
            new NonDrivingContactMediumWarning(3, notifier)
          }).toThrow(TypeError)

          expect(() => {
            // eslint-disable-next-line no-new
            new NonDrivingContactMediumWarning($('#non-existant'), notifier)
          }).toThrow(ReferenceError)

          done()
        } catch (error) {
          done(error)
        }
      })
    })
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
