/* global $ */
const TypeChecker = require('./type_checker.js')

class Notification {
  constructor (notificationElementAsJQuery) {
    TypeChecker.checkNonEmptyJQueryObject(notificationElementAsJQuery, 'notificationElementAsJQuery')

    this.notificationElement = notificationElementAsJQuery
  }

  dismiss () {

  }

  getText () {

  }

  isDismissable () {

  }

  isDismissed () {

  }

  setDismissable () {

  }

  setText () {

  }

  toggleDismissable () {

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

    let classPrefixMessage = ''
    let classSuffixDismissButton = ''
    const escapedMessage = message.replace(/&/g, '&amp;')
      .replace(/>/g, '&gt;')
      .replace(/</g, '&lt;')
      .replace(/"/g, '&quot;')
      .replace(/'/g, '&apos;')

    switch (level) {
      case 'error':
        classPrefixMessage = 'failure'
        classSuffixDismissButton = 'danger'

        break
      case 'info':
        classPrefixMessage = 'success'
        classSuffixDismissButton = 'success'

        break
      case 'warn':
        classPrefixMessage = 'warn'
        classSuffixDismissButton = 'warning'

        break
      default:
        throw new RangeError('Unsupported option for param level')
    }

    const dismissButtonAsHTML = isDismissable ? `<button class="btn btn-${classSuffixDismissButton} btn-sm">×</button>` : ''
    const newNotification =
      $(
        `<div class="${classPrefixMessage}-indicator">
          ${escapedMessage}
          ${dismissButtonAsHTML}
        </div>`
      )

    this.notificationsElement.append(newNotification)

    if (isDismissable) {
      newNotification.children('button').on('click', function () {
        $(this).parent().remove()
      })
    }

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
