/* global $ */
import { escape } from 'lodash'

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
  constructor (notificationElementAsJQuery, parentNotifier) {
    TypeChecker.checkNonEmptyJQueryObject(notificationElementAsJQuery, 'notificationElementAsJQuery')

    if (!(parentNotifier instanceof Notifier)) {
      throw new TypeError('Param parentNotifier must be an instance of Notifier')
    }

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

    notificationElementAsJQuery.children('button').on('click', () => {
      this.dismiss()
    })

    this.notificationElement = notificationElementAsJQuery
    this.parentNotifier = parentNotifier
  }

  dismiss () {
    this.#throwErrorIfDismissed()

    this.notificationElement.remove()
    this.parentNotifier.notificationsCount[this.level]--
  }

  getText () {
    return this.notificationElement.children('span').text()
  }

  isUserDismissable () {
    return this.notificationElement.children('button').length
  }

  isDismissed () {
    return !($('#notifications').find(this.notificationElement).length)
  }

  setUserDismissable (dismissable) {
    this.#throwErrorIfDismissed()

    if (dismissable && !(this.isUserDismissable())) {
      this.#userDismissableEnable()
    } else if (!dismissable && this.isUserDismissable()) {
      this.#userDismissableDisable()
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

    if (this.isUserDismissable()) {
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

    dismissButton.on('click', () => {
      this.dismiss()
    })
  }
}

class Notifier {
  //  @param {object} notificationsElement The notification DOM element as a jQuery object
  constructor (notificationsElement) {
    TypeChecker.checkNonEmptyJQueryObject(notificationsElement, 'notificationsElement')

    const outer = this

    this.loadingToast = notificationsElement.find('#async-waiting-indicator')
    this.notificationsCount = new Proxy({
      error: 0,
      info: 0,
      warn: 0
    }, {
      set(target, propertyKey, value) {
        const defaultSet = Reflect.set(target, propertyKey, value)

        if (outer.totalNotificationCount()) {
          outer.setMinimizeButtonVisibility(true)
        } else {
          outer.setMinimizeButtonVisibility(false)
        }

        return defaultSet
      }
    })
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

    const escapedMessage = escape(message)

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

    const newNotification = new Notification(newNotificationAsJQuery, this)

    this.notificationsCount[level]++

    return newNotification
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

  setMinimizeButtonVisibility (visible) {
    if (visible) {
      this.notificationsElement.children('button').show()
    } else {
      this.notificationsElement.children('button').hide()
    }
  }

  totalNotificationCount () {
    return Object.values(this.notificationsCount).reduce((acc, currentValue) => {
      return acc + currentValue
    }, 0)
  }

  // Shows a loading indicator until all operations resolve
  waitForAsyncOperation () {
    this.loadingToast.show()
    this.waitingAsyncOperationCount++
  }
}

module.exports = { Notifier, Notification }
