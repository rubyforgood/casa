/* global $ */
const TypeChecker = require('./type_checker.js')

const levels = {
  error: {
    classPrefixMessage: 'failure',
    classSuffixDismissButton: 'danger'
  },

  info: {
    classPrefixMessage: 'success',
    classSuffixDismissButton: 'success'
  },

  warn: {
    classPrefixMessage: 'warn',
    classSuffixDismissButton: 'warning'
  }
}

class Notification {
  constructor (notificationElementAsJQuery) {
    TypeChecker.checkNonEmptyJQueryObject(notificationElementAsJQuery, 'notificationElementAsJQuery')

    const levelCapturedViaClassNames = notificationElementAsJQuery.attr('class').match(/(warn|failure|success)-indicator/)

    if (!levelCapturedViaClassNames) {
      throw new RangeError('Failed to parse notification level from notification level class')
    }

    this.level = levelCapturedViaClassNames[1]

    if (this.level === 'failure') {
      this.level = 'error'
    } else if (this.level === 'success') {
      this.level = 'info'
    }

    this.notificationElement = notificationElementAsJQuery
  }

  dismiss () {
    this.#throwErrorIfDismissed()

    this.notificationElement.remove()
  }

  getText () {
    return this.notificationElement.children('span').text()
  }

  isDismissable () {
    return this.notificationElement.children('button').length
  }

  isDismissed () {
    return !($('#notifications').find(this.notificationElement).length)
  }

  setUserDismissable (dismissable) {
    this.#throwErrorIfDismissed()

    if (dismissable && !(this.isDismissable())) {
      this.#userDismissableDisable()
    } else if (!dismissable && this.isDismissable()) {
      this.#userDismissableEnable()
    }
  }

  setText (newText) {
    this.#throwErrorIfDismissed()
    TypeChecker.checkString(newText, 'newText')

    return this.notificationElement.children('span').text(newText)
  }

  #throwErrorIfDismissed () {
    if (this.isDismissed()) {
      throw new ReferenceError('Invalid Operation. This notification has been dismissed.')
    }
  }

  toggleUserDismissable () {
    this.#throwErrorIfDismissed()

    if (this.isDismissable()) {
      this.#userDismissableDisable()
    } else {
      this.#userDismissableEnable()
    }
  }

  #userDismissableDisable () {
    this.notificationElement.children('button').remove()
  }

  #userDismissableEnable () {
    const dismissButton = $(`<button class="btn btn-${levels[this.level].classSuffixDismissButton} btn-sm">×</button>`)
    this.notificationElement.append(dismissButton)

    dismissButton.on('click', function () {
      $(this).parent().remove()
    })
  }
}

class Notifier {
  //  @param {object} notificationsElement The notification DOM element as a jQuery object
  constructor (notificationsElement) {
    TypeChecker.checkNonEmptyJQueryObject(notificationsElement, 'notificationsElement')

    this.loadingToast = notificationsElement.find('#async-waiting-indicator')
    this.notificationsElement = notificationsElement
    this.savedToast = notificationsElement.find('#async-success-indicator')
    this.savedToastTimeouts = []
    this.waitingAsyncOperationCount = 0
  }

  // Adds notification messages to the notification element
  //  @param   {string} message The message to be displayed
  //  @param   {string} level One of the following logging levels
  //    "error"  Shows a red notification
  //    "info"   Shows a green notification
  //    "warn"   Shows an orange notification
  //  @returns {jQuery} a jQuery object representing the new notification
  //  @throws  {TypeError}  for a parameter of the incorrect type
  //  @throws  {RangeError} for unsupported logging levels

  notify (message, level, isDismissable = true) {
    TypeChecker.checkString(message, 'message')

    const escapedMessage = message.replace(/&/g, '&amp;')
      .replace(/>/g, '&gt;')
      .replace(/</g, '&lt;')
      .replace(/"/g, '&quot;')
      .replace(/'/g, '&apos;')

    if (!(levels[level])) {
      throw new RangeError('Unsupported option for param level')
    }

    const dismissButtonAsHTML = isDismissable ? `<button class="btn btn-${levels[level].classSuffixDismissButton} btn-sm">×</button>` : ''
    const newNotificationAsJQuery =
      $(
        `<div class="${levels[level].classPrefixMessage}-indicator">
          <span>${escapedMessage}</span>
          ${dismissButtonAsHTML}
        </div>`
      )

    this.notificationsElement.append(newNotificationAsJQuery)

    if (isDismissable) {
      newNotificationAsJQuery.children('button').on('click', function () {
        $(this).parent().remove()
      })
    }

    const newNotification = new Notification(newNotificationAsJQuery)
    console.log(newNotification)
    return newNotification
  }

  // Shows a loading indicator until all operations resolve
  waitForAsyncOperation () {
    this.loadingToast.show()
    this.waitingAsyncOperationCount++
  }

  // Shows the saved toast for 2 seconds and hides the loading indicator if no more async operations are pending
  //  @param  {string=}  error The error to be displayed(optional)
  //  @throws {Error}    for trying to resolve more async operations than the amount currently awaiting
  resolveAsyncOperation (errorMsg) {
    if (this.waitingAsyncOperationCount < 1) {
      const resolveNonexistantOperationError = 'Attempted to resolve an async operation when awaiting none'
      this.notify(resolveNonexistantOperationError, 'error')
      throw new Error(resolveNonexistantOperationError)
    }

    this.waitingAsyncOperationCount--

    if (this.waitingAsyncOperationCount === 0) {
      this.loadingToast.hide()
    }

    if (!errorMsg) {
      this.savedToast.show()

      this.savedToastTimeouts.forEach((timeoutID) => {
        clearTimeout(timeoutID)
      })

      this.savedToastTimeouts.push(setTimeout(() => {
        this.savedToast.hide()
        this.savedToastTimeouts.shift()
      }, 2000))
    } else {
      if (!(typeof errorMsg === 'string' || errorMsg instanceof String)) {
        throw new TypeError('Param errorMsg must be a string')
      }

      this.notify(errorMsg, 'error')
    }
  }
}

module.exports = { Notifier, Notification }
