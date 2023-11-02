/* global $ */
import { debounce } from 'lodash'
const { Notifier } = require('./notifier')
const TypeChecker = require('./type_checker')

const GET_ERROR_STATE_UNDEFINED_MESSAGE = 'getErrorState for the component is not defined'
const GET_WARNING_STATE_UNDEFINED_MESSAGE = 'getWarningState for the component is not defined'

// Abstract Class
class ValidatableFormSectionComponent {
  constructor (componentElementsAsJQuery, notifier) {
    TypeChecker.checkNonEmptyJQueryObject(componentElementsAsJQuery, 'componentElementsAsJQuery')

    if (!(notifier instanceof Notifier)) {
      console.error('Warning: unable to show notifications to the user')
    } else {
      this.notifier = notifier
    }

    this.componentElementsAsJQuery = componentElementsAsJQuery
  }

  clearUserError () {
    // Removes the error displayed to the user
    throw new ReferenceError('clearUserError for the component is not defined')
  }

  // @param  {string} errorState The value returned by getErrorState()
  errorHighlightUI (errorState) {
    // Highlights the error input area for the user to see easier
    // If there is no error, returns the component back to the original state
    throw new ReferenceError('errorHighlightUI for the component is not defined')
  }

  // @returns A string describing the invalid state of the inputs for the user to read, empty string if the inputs are valid
  getErrorState () {
    throw new ReferenceError(GET_ERROR_STATE_UNDEFINED_MESSAGE)
  }

  // @returns A string describing the potentially invalid state of the inputs for the user to read, empty string if there is nothing to warn about
  getWarningState () {
    throw new ReferenceError(GET_WARNING_STATE_UNDEFINED_MESSAGE)
  }

  notifyUserOfError (errorMsg) {
    // Shows the error message to the user
    throw new ReferenceError('notifyUserOfError for the component is not defined')
  }

  validate () {
    let errorMsg
    let errorValidationDisabled = false
    let warningMsg
    let warningValidationDisabled = false

    try {
      errorMsg = this.#validateError()
    } catch (err) {
      if (err instanceof ReferenceError && err.message === GET_ERROR_STATE_UNDEFINED_MESSAGE) {
        errorValidationDisabled = true
      } else {
        throw err
      }
    }

    try {
      warningMsg = this.#validateWarning()
    } catch (err) {
      if (err instanceof ReferenceError && err.message === GET_WARNING_STATE_UNDEFINED_MESSAGE) {
        warningValidationDisabled = true
      } else {
        throw err
      }
    }

    if (errorValidationDisabled && warningValidationDisabled) {
      throw new ReferenceError('No validations are implemented for this component')
    }

    const messages = {}

    if (errorMsg) {
      messages.error = errorMsg
    }

    if (warningMsg) {
      messages.warning = warningMsg
    }

    return messages
  }

  #validateError () {
    const errorState = this.getErrorState()

    if (errorState) {
      this.notifyUserOfError(errorState)
    } else {
      this.clearUserError()
    }

    this.errorHighlightUI(errorState)
    return errorState
  }

  #validateWarning () {
    const warningState = this.getWarningState()

    this.warningHighlightUI(warningState)

    return warningState
  }

  // @param  {string} errorState The value returned by getWarningState()
  warningHighlightUI (errorState) {
    // Highlights the warning input area for the user to see easier
    // Also appends a required checkbox near the warning area with warning text
    // If there is no warning, returns the component back to the original state
    throw new ReferenceError('warningHighlightUI for the component is not defined')
  }
}

class RangedDatePicker extends ValidatableFormSectionComponent {
  constructor (componentElementsAsJQuery, notifier) {
    super(componentElementsAsJQuery, notifier)

    const maxDateValue = this.componentElementsAsJQuery.attr('data-max-date')
    const minDateValue = this.componentElementsAsJQuery.attr('data-min-date')
    this.name = this.componentElementsAsJQuery.attr('component-name')

    this.max = maxDateValue === 'today' ? new Date() : new Date(maxDateValue)
    this.min = minDateValue === 'today' ? new Date() : new Date(minDateValue)

    if (this.min instanceof Date && this.max instanceof Date && max < min) {
      throw new RangeError('The minimum date for the component was set to be later than the maximum date')
    }
  }

  clearUserError () {
    if (this.errorNotification) {
      this.errorNotification.dismiss()
      this.errorNotification = undefined
    }
  }

  errorHighlightUI (errorState) {
    if (errorState) {
      this.componentElementsAsJQuery.css('border', '2px solid red')
    } else {
      this.componentElementsAsJQuery.css('border', '')
    }
  }

  getErrorState () {
    const setDate = new Date(this.componentElementsAsJQuery.val())
    const { max, min } = this

    if (setDate > max && !isNaN(max)) {
      return `Date for ${this.name} is past maximum allowed date of ${max.toDateString()}`
    } else if (setDate < min && !isNaN(min)) {
      return `Date for ${this.name} is behind minimum allowed date of ${min.toDateString()}`
    }
  }

  notifyUserOfError (errorMsg) {
    TypeChecker.checkNonEmptyString(errorMsg, 'errorMsg')

    if (this.errorNotification) {
      this.errorNotification.setText(errorMsg)
    } else if (this.notifier) {
      this.errorNotification = this.notifier.notify(errorMsg, 'error', false)
    }
  }
}

$(() => { // JQuery's callback for the DOM loading
  const validatedFormCollection = $('.component-validated-form')
  const validatableFormSectionComponents = []
  let pageNotifier
  let formErrorCountNotification

  if (validatedFormCollection.length) {
    const notificationsElement = $('#notifications')
    pageNotifier = notificationsElement.length ? new Notifier(notificationsElement) : null
  }

  validatedFormCollection.find('.component-date-picker-range').each(function () {
    try {
      validatableFormSectionComponents.push(new RangedDatePicker($(this), pageNotifier))
    } catch (e) {
      console.error('Failed to instantiate ranged date picker with the following jQuery object:')
      console.error($(this))
      console.error(e)
    }
  })

  validatedFormCollection.on('submit', function (e) {
    let errorCount = 0

    for (const validatableFormSectionComponent of validatableFormSectionComponents) {
      try {
        if (validatableFormSectionComponent.validate().error) {
          errorCount++
        }
      } catch (err) {
        console.error('Failed to validate the following component:', validatableFormSectionComponent)
        console.error('Validation threw error:', err)
      }
    }

    if (errorCount) {
      e.preventDefault()

      if (formErrorCountNotification) {
        formErrorCountNotification.setText(`${errorCount} error${errorCount > 1 ? 's' : ''} need${errorCount > 1 ? '' : 's'} to be fixed before you can submit.`)
      } else {
        formErrorCountNotification = pageNotifier.notify(`${errorCount} error${errorCount > 1 ? 's' : ''} need${errorCount > 1 ? '' : 's'} to be fixed before you can submit.`, 'error', false)
      }
    } else {
      if (formErrorCountNotification) {
        formErrorCountNotification.dismiss()
        $(e.currentTarget).trigger('submit')
      }
    }
  })
})
