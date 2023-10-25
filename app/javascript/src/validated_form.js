/* global $ */
const { Notifier } = require('./notifier')
const TypeChecker = require('./type_checker')

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
    throw new ReferenceError('clearUserError for the component is not defined')
  }

  // @param  {string} errorState The value returned by getErrorState()
  errorHighlightUI (errorState) {
    throw new ReferenceError('errorHighlightUI for the component is not defined')
  }

  // @returns A string describing the invalid state of the inputs for the user to read, empty string if the inputs are valid
  getErrorState () {
    throw new ReferenceError('getErrorState for the component is not defined')
  }

  notifyUserOfError (errorMsg) {
    throw new ReferenceError('notifyUserOfError for the component is not defined')
  }

  validate () {
    const errorState = this.getErrorState()

    if (errorState) {
      this.notifyUserOfError(errorState)
    } else {
      this.clearUserError()
    }

    this.errorHighlightUI(errorState)
    return errorState
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
    const errorCount = validatableFormSectionComponents.reduce((acc, currentComponent) => {
      return currentComponent.validate() ? acc + 1 : acc
    }, 0)

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
