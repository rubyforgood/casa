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
  let checkboxes
  let drivingOption
  let milesDrivenInput
  let nonDrivingOptions
  let notifier

  beforeEach(() => {
    document.body.innerHTML =
`<form class="component-validated-form">
  <div class="field contact-medium form-group">
    <h5 classs="mb-3"><label for="case_contact_medium_type">b. Contact Medium</label></h5>
    <input type="hidden" name="case_contact[medium_type]" value="" autocomplete="off">
    <div class="form-check radio-style mb-20">
      <input class="form-check-input" type="radio" value="in-person" name="case_contact[medium_type]" id="case_contact_medium_type_in-person">
      <label class="form-check-label" for="case_contact_medium_type_in-person">In Person</label>
    </div>
    <div class="form-check radio-style mb-20">
      <input class="form-check-input" type="radio" value="text/email" checked="checked" name="case_contact[medium_type]" id="case_contact_medium_type_textemail">
      <label class="form-check-label" for="case_contact_medium_type_textemail">Text/Email</label>
    </div>

    <div class="form-check radio-style mb-20">
      <input class="form-check-input" type="radio" value="video" name="case_contact[medium_type]" id="case_contact_medium_type_video">
      <label class="form-check-label" for="case_contact_medium_type_video">Video</label>
    </div>

    <div class="form-check radio-style mb-20">
      <input class="form-check-input" type="radio" value="voice-only" name="case_contact[medium_type]" id="case_contact_medium_type_voice-only">
      <label class="form-check-label" for="case_contact_medium_type_voice-only">Voice Only</label>
    </div>

    <div class="form-check radio-style mb-20">
      <input class="form-check-input" type="radio" value="letter" name="case_contact[medium_type]" id="case_contact_medium_type_letter">
      <label class="form-check-label" for="case_contact_medium_type_letter">Letter</label>
    </div>
  </div>

  <div class="field miles-driven form-group">
    <h5 class="mb-3"><label for="case_contact_miles_driven">a. Miles Driven</label></h5>
    <div class="input-style-1">
      <input class="form-control" min="0" max="10000" type="number" value="0" name="case_contact[miles_driven]" autocomplete="off" id="case_contact_miles_driven">
    </div>
  </div>
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
      checkboxes = $('.contact-medium.form-group input:not([type=hidden])')
      drivingOption = checkboxes.filter('#case_contact_medium_type_in-person')
      milesDrivenInput = $('#case_contact_miles_driven')
      nonDrivingOptions = checkboxes.not(drivingOption)
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

  describe('getWarningState', () => {
    let component

    beforeEach(() => {
      component = new NonDrivingContactMediumWarning($('.contact-medium.form-group input:not([type=hidden]), #case_contact_miles_driven'), notifier)
    })

    test('returns the warning message if a non driving contact medium is selected and the miles driven count is > 0', (done) => {
      $(() => {
        try {
          expect(nonDrivingOptions.length).toBeGreaterThan(0)

          milesDrivenInput.val(1)

          nonDrivingOptions.each(function () {
            const option = $(this)

            option.trigger('click')

            expect(component.getWarningState()).toBe('You requested driving reimbursement for a contact medium that typically does not involve driving. Are you sure that\'s right?')
          })

          done()
        } catch (error) {
          done(error)
        }
      })
    })

    test('returns a falsy value if the driving contact medium is selected or the miles driven count is 0', (done) => {
      $(() => {
        try {
          expect(nonDrivingOptions.length).toBeGreaterThan(0)

          milesDrivenInput.val(0)

          nonDrivingOptions.each(function () {
            const option = $(this)

            option.trigger('click')

            expect(component.getWarningState()).toBeFalsy()
          })

          milesDrivenInput.val(1)
          drivingOption.trigger('click')

          expect(component.getWarningState()).toBeFalsy()

          done()
        } catch (error) {
          done(error)
        }
      })
    })
  })

  describe('warningHighlightUI', () => {
    let checkboxContainer
    let component

    beforeEach(() => {
      $(() => {
        checkboxContainer = $('.contact-medium.form-group')
        component = new NonDrivingContactMediumWarning($('.contact-medium.form-group input:not([type=hidden]), #case_contact_miles_driven'), notifier)
      })
    })

    test('when passed a truthy value, it makes the parent container for the checkboxes yellow and draws a yellow border around the miles driven input', (done) => {
      $(() => {
        try {
          expect(checkboxContainer.css('background-color')).not.toBe('rgb(255, 248, 225)')
          expect(milesDrivenInput.css('border')).not.toBe('2px solid #ffc107')

          component.warningHighlightUI('A warning message')

          expect(checkboxContainer.css('background-color')).toBe('rgb(255, 248, 225)')
          expect(milesDrivenInput.css('border')).toBe('2px solid #ffc107')
          done()
        } catch (error) {
          done(error)
        }
      })
    })

    test('when passed a falsy value, it removes the error highlighting', (done) => {
      $(() => {
        try {
          expect(checkboxContainer.css('background-color')).not.toBe('rgb(255, 248, 225)')
          expect(milesDrivenInput.css('border')).not.toBe('2px solid #ffc107')

          component.warningHighlightUI('A warning message')

          expect(checkboxContainer.css('background-color')).toBe('rgb(255, 248, 225)')
          expect(milesDrivenInput.css('border')).toBe('2px solid #ffc107')

          component.warningHighlightUI()

          expect(checkboxContainer.css('background-color')).not.toBe('rgb(255, 248, 225)')
          expect(milesDrivenInput.css('border')).not.toBe('2px solid #ffc107')

          done()
        } catch (error) {
          done(error)
        }
      })
    })
  })

  describe('showUserWarning', () => {
    let component
    let notifierElement

    beforeEach(() => {
      $(() => {
        component = new NonDrivingContactMediumWarning($('.contact-medium.form-group input:not([type=hidden]), #case_contact_miles_driven'), notifier)
        notifierElement = $('#notifications')
      })
    })

    test('it shows the user a warning through the notifier', (done) => {
      $(() => {
        try {
          const warningText = 'Q~Au\\`FMET"["8.JKB_M'

          component.showUserWarning(warningText)

          const notifications = notifierElement.find('.warning-notification')
          expect(notifications[0].innerHTML).toContain(warningText)

          done()
        } catch (error) {
          done(error)
        }
      })
    })

    test('idempotence test', (done) => {
      $(() => {
        try {
          const warningText = 'Q~Au\\`FMET"["8.JKB_M'

          component.showUserWarning(warningText)
          component.showUserWarning(warningText)

          const notifications = notifierElement.find('.warning-notification')
          expect(notifications[0].innerHTML).toContain(warningText)
          expect(notifications.length).toBe(1)

          done()
        } catch (error) {
          done(error)
        }
      })
    })
  })

  describe('removeUserWarning', () => {
    let component
    let notifierElement

    beforeEach(() => {
      $(() => {
        component = new NonDrivingContactMediumWarning($('.contact-medium.form-group input:not([type=hidden]), #case_contact_miles_driven'), notifier)
        notifierElement = $('#notifications')
      })
    })

    test('it removes the user warning if it is present', (done) => {
      $(() => {
        try {
          const warningText = 'Q~Au\\`FMET"["8.JKB_M'

          component.showUserWarning(warningText)
          const componentNotification = component.warningNotification

          let notifications = notifierElement.find('.warning-notification')
          expect(notifications[0].innerHTML).toContain(warningText)
          expect(componentNotification.isDismissed()).toBe(false)

          component.removeUserWarning()

          notifications = notifierElement.find('.warning-notification')
          expect(notifications.length).toBe(0)
          expect(componentNotification.isDismissed()).toBe(true)
          done()
        } catch (error) {
          done(error)
        }
      })
    })

    test('idempotence test', (done) => {
      $(() => {
        try {
          const warningText = 'Q~Au\\`FMET"["8.JKB_M'

          component.showUserWarning(warningText)
          const componentNotification = component.warningNotification

          let notifications = notifierElement.find('.warning-notification')
          expect(notifications[0].innerHTML).toContain(warningText)
          expect(componentNotification.isDismissed()).toBe(false)

          component.removeUserWarning()
          component.removeUserWarning()

          notifications = notifierElement.find('.warning-notification')
          expect(notifications.length).toBe(0)
          expect(componentNotification.isDismissed()).toBe(true)
          done()
        } catch (error) {
          done(error)
        }
      })
    })
  })

  describe('showWarningConfirmation', () => {
    let component

    beforeEach(() => {
      $(() => {
        component = new NonDrivingContactMediumWarning($('.contact-medium.form-group input:not([type=hidden]), #case_contact_miles_driven'), notifier)
      })
    })

    test('it adds the required checkbox with the warning label', (done) => {
      $(() => {
        try {
          expect($('input#warning-non-driving-contact-medium-check[required=true]').length).toBe(0)

          component.showWarningConfirmation()

          expect($('input#warning-non-driving-contact-medium-check[required=true]').length).toBe(1)
          expect($('label[for=warning-non-driving-contact-medium-check]').text()).toBe('I\'m sure I drove for this contact medium.')
          done()
        } catch (error) {
          done(error)
        }
      })
    })

    test('idempotence test', (done) => {
      $(() => {
        try {
          expect($('input#warning-non-driving-contact-medium-check[required=true]').length).toBe(0)

          component.showWarningConfirmation()
          component.showWarningConfirmation()

          expect($('input#warning-non-driving-contact-medium-check[required=true]').length).toBe(1)
          expect($('label[for=warning-non-driving-contact-medium-check]').text()).toBe('I\'m sure I drove for this contact medium.')
          done()
        } catch (error) {
          done(error)
        }
      })
    })
  })

  describe('removeWarningConfirmation', () => {
    let component

    beforeEach(() => {
      $(() => {
        component = new NonDrivingContactMediumWarning($('.contact-medium.form-group input:not([type=hidden]), #case_contact_miles_driven'), notifier)
      })
    })

    test('it removes the required checkbox with the warning label', (done) => {
      $(() => {
        try {
          component.showWarningConfirmation()

          expect($('input#warning-non-driving-contact-medium-check[required=true]').length).toBe(1)
          expect($('label[for=warning-non-driving-contact-medium-check]').text()).toBe('I\'m sure I drove for this contact medium.')

          component.removeWarningConfirmation()

          expect($('input#warning-non-driving-contact-medium-check[required=true]').length).toBe(0)
          done()
        } catch (error) {
          done(error)
        }
      })
    })

    test('idempotence test', (done) => {
      $(() => {
        try {
          component.showWarningConfirmation()

          expect($('input#warning-non-driving-contact-medium-check[required=true]').length).toBe(1)
          expect($('label[for=warning-non-driving-contact-medium-check]').text()).toBe('I\'m sure I drove for this contact medium.')

          component.removeWarningConfirmation()
          component.removeWarningConfirmation()

          expect($('input#warning-non-driving-contact-medium-check[required=true]').length).toBe(0)
          done()
        } catch (error) {
          done(error)
        }
      })
    })
  })
})
