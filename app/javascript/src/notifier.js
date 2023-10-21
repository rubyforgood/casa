/* global $ */
import { escape } from 'lodash'

const TypeChecker = require('./type_checker.js')

const levelClasses = {
  error: 'danger',
  info: 'success',
  warn: 'warning'
}

class Notification {
  constructor (notificationElementAsJQuery, parentNotifier) {
    TypeChecker.checkNonEmptyJQueryObject(notificationElementAsJQuery, 'notificationElementAsJQuery')

    if (!(parentNotifier instanceof Notifier)) {
      throw new TypeError('Param parentNotifier must be an instance of Notifier')
    }

    const levelCapturedViaClassNames = notificationElementAsJQuery.attr('class').match(/(warning|danger|success)-notification/)

    if (!levelCapturedViaClassNames) {
      throw new RangeError('Failed to parse notification level from notification level class')
    }

    this.level = levelCapturedViaClassNames[1]

    if (this.level === 'danger') {
      this.level = 'error'
    } else if (this.level === 'success') {
      this.level = 'info'
    } else if (this.level === 'warning') {
      this.level = 'warn'
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
    const dismissButton = $(`<button class="btn btn-${levelClasses[this.level]} btn-sm">×</button>`)
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

    this.elements = {
      loadingToast: notificationsElement.find('#async-waiting-indicator'),
      messageCountBadges: {
        all: notificationsElement.find('#toggle-minimize-notifications .badge'),
        error: notificationsElement.find('#toggle-minimize-notifications .bg-danger'),
        info: notificationsElement.find('#toggle-minimize-notifications .bg-success'),
        warn: notificationsElement.find('#toggle-minimize-notifications .bg-warning')
      },
      messagesContainer: notificationsElement.children('.messages'),
      minimizeButton: notificationsElement.children('#toggle-minimize-notifications'),
      minimizeButtonIcon: notificationsElement.find('#toggle-minimize-notifications fa-solid'),
      minimizeButtonText: notificationsElement.find('#toggle-minimize-notifications span').first(),
      notificationsElement,
      savedToast: notificationsElement.find('#async-success-indicator')
    }

    this.notificationsCount = new Proxy({
      error: 0,
      info: 0,
      warn: 0
    }, {
      set (target, propertyKey, value) {
        const defaultSet = Reflect.set(target, propertyKey, value)

        if (outer.totalNotificationCount()) {
          outer.#setMinimizeButtonVisibility(true)
        } else {
          outer.#setMinimizeButtonVisibility(false)
        }

        const levelBadge = outer.elements.messageCountBadges[propertyKey]

        levelBadge.text(value)

        if (value && outer.elements.messagesContainer.css('display') === 'none') {
          levelBadge.show()
        } else {
          levelBadge.hide()
        }

        return defaultSet
      }
    })

    this.savedToastTimeouts = []
    this.waitingAsyncOperationCount = 0

    this.elements.minimizeButton.on('click', () => {
      this.toggleMinimize()
    })
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

    if (!(levelClasses[level])) {
      throw new RangeError('Unsupported option for param level')
    }

    const dismissButtonAsHTML = isDismissable ? `<button class="btn btn-${levelClasses[level]} btn-sm">×</button>` : ''
    const newNotificationAsJQuery =
      $(
        `<div class="${levelClasses[level]}-notification">
          <span>${escapedMessage}</span>
          ${dismissButtonAsHTML}
        </div>`
      )

    this.elements.messagesContainer.append(newNotificationAsJQuery)

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
      this.elements.loadingToast.hide()
    }

    if (!errorMsg) {
      this.elements.savedToast.show()

      this.savedToastTimeouts.forEach((timeoutID) => {
        clearTimeout(timeoutID)
      })

      this.savedToastTimeouts.push(setTimeout(() => {
        this.elements.savedToast.hide()
        this.savedToastTimeouts.shift()
      }, 2000))
    } else {
      if (!(typeof errorMsg === 'string' || errorMsg instanceof String)) {
        throw new TypeError('Param errorMsg must be a string')
      }

      this.notify(errorMsg, 'error')
    }
  }

  #setMinimizeButtonVisibility (visible) {
    if (visible) {
      this.elements.minimizeButton.show()
    } else {
      this.elements.minimizeButton.hide()
    }
  }

  toggleMinimize () {
    const { messagesContainer } = this.elements

    if (messagesContainer.css('display') === 'none') {
      messagesContainer.show()
      this.elements.minimizeButtonText.show()
      this.elements.messageCountBadges.all.hide()
      this.elements.minimizeButtonIcon.removeClass('fa-plus').addClass('fa-minus')
    } else {
      messagesContainer.hide()

      for (const level in this.notificationsCount) {
        const levelMessageCount = this.notificationsCount[level]

        if (levelMessageCount) {
          const levelBadge = this.elements.messageCountBadges[level]
          levelBadge.show()
        }
      }

      this.elements.minimizeButtonText.hide()
      this.elements.minimizeButtonIcon.removeClass('fa-minus').addClass('fa-plus')
    }
  }

  totalNotificationCount () {
    return Object.values(this.notificationsCount).reduce((acc, currentValue) => {
      return acc + currentValue
    }, 0)
  }

  // Shows a loading indicator until all operations resolve
  waitForAsyncOperation () {
    this.elements.loadingToast.show()
    this.waitingAsyncOperationCount++
  }
}

module.exports = { Notifier, Notification }
