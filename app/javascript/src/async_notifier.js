/* global $ */
const TypeChecker = require('./type_checker.js')

module.exports = class Notifier {
  //  @param {object} notificationsElement The notification DOM element as a jQuery object
  constructor (notificationsElement) {
    TypeChecker.checkNonEmptyJQueryObject(notificationsElement, 'notificationsElement')

    this.loadingToast = notificationsElement.find('#async-waiting-indicator')
    this.notificationsElement = notificationsElement
    this.savedToast = notificationsElement.find('#async-success-indicator')
    this.savedToastTimeouts = []
    this.waitingSaveOperationCount = 0
  }

  // Adds notification messages to the notification element
  //  @param  {string} message The message to be displayed
  //  @param  {string} level One of the following logging levels
  //    "error"  Shows a red notification
  //    "info"   Shows a green notification
  //    "warn"   Shows an orange notification
  //  @throws {TypeError}  for a parameter of the incorrect type
  //  @throws {RangeError} for unsupported logging levels

  notify (message, level) {
    TypeChecker.checkString(message, 'message')

    const escapedMessage = message.replace(/&/g, '&amp;')
      .replace(/>/g, '&gt;')
      .replace(/</g, '&lt;')
      .replace(/"/g, '&quot;')
      .replace(/'/g, '&apos;')

    switch (level) {
      case 'error':
        this.notificationsElement.append(`
          <div class="async-failure-indicator">
            Error: ${escapedMessage}
            <button class="btn btn-danger btn-sm">×</button>
          </div>`)
          .find('.async-failure-indicator button').click(function () {
            $(this).parent().remove()
          })

        break
      case 'info':
        this.notificationsElement.append(`
          <div class="async-success-indicator">
            ${escapedMessage}
            <button class="btn btn-success btn-sm">×</button>
          </div>`)
          .find('.async-success-indicator button').click(function () {
            $(this).parent().remove()
          })

        break
      case 'warn':
        this.notificationsElement.append(`
          <div class="async-warn-indicator">
            ${escapedMessage}
            <button class="btn btn-warning btn-sm">×</button>
          </div>`)
          .find('.async-warn-indicator button').click(function () {
            $(this).parent().remove()
          })

        break
      default:
        throw new RangeError('Unsupported option for param level')
    }
  }

  // Shows the loading toast
  startAsyncOperation () {
    this.loadingToast.show()
    this.waitingSaveOperationCount++
  }

  // Shows the saved toast for 2 seconds
  //  @param  {string=}  error The error to be displayed(optional)
  //  @throws {Error}    for trying to resolve more async operations than the amount currently awaiting
  stopAsyncOperation (errorMsg) {
    if (this.waitingSaveOperationCount < 1) {
      const resolveNonexistantOperationError = 'Attempted to resolve an async operation when awaiting none'
      this.notify(resolveNonexistantOperationError, 'error')
      throw new Error(resolveNonexistantOperationError)
    }

    this.waitingSaveOperationCount--

    if (this.waitingSaveOperationCount === 0) {
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
