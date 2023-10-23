/* eslint-env jest */
import { escape } from 'lodash'

require('jest')
const { Notifier, Notification } = require('../src/notifier.js')

let notificationsElement
let notifier

beforeEach(() => {
  document.body.innerHTML = `<div id="notifications">
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
    notificationsElement = $('#notifications')
    notifier = new Notifier(notificationsElement)
  })
})

describe('Notifier', () => {
  describe('clicking the minify button', () => {
    let minimizeButton

    beforeEach(() => { // Create a notification so the minify button displays
      $(() => {
        notifier.notify('a notification', 'info')
        minimizeButton = notificationsElement.find('#toggle-minimize-notifications')
      })
    })

    test('should toggle the notifier between the minified and expanded state', (done) => {
      $(() => {
        try {
          const messageNotificationsContainer = notificationsElement.find('.messages')
          const minimizeButtonIcon = minimizeButton.children('i')
          const minimizeButtonText = minimizeButton.children('span').first()

          expect(minimizeButton.css('display')).not.toBe('none')
          expect(messageNotificationsContainer.css('display')).not.toBe('none')
          expect(minimizeButtonIcon.hasClass('fa-minus')).toBeTruthy()
          expect(minimizeButtonIcon.hasClass('fa-plus')).not.toBeTruthy()
          expect(minimizeButtonText.css('display')).not.toBe('none')

          minimizeButton.click()

          expect(messageNotificationsContainer.css('display')).toBe('none')
          expect(minimizeButtonIcon.hasClass('fa-minus')).not.toBeTruthy()
          expect(minimizeButtonIcon.hasClass('fa-plus')).toBeTruthy()
          expect(minimizeButtonText.css('display')).toBe('none')

          minimizeButton.click()

          expect(messageNotificationsContainer.css('display')).not.toBe('none')
          expect(minimizeButtonIcon.hasClass('fa-minus')).toBeTruthy()
          expect(minimizeButtonIcon.hasClass('fa-plus')).not.toBeTruthy()
          expect(minimizeButtonText.css('display')).not.toBe('none')

          done()
        } catch (error) {
          done(error)
        }
      })
    })

    test('should show only badges where there exists at least one notification matching the badge level when minimized', (done) => {
      $(() => {
        try {
          const minimizeButtonBadgeError = minimizeButton.children('.bg-danger')
          const minimizeButtonBadgeInfo = minimizeButton.children('.bg-success')
          const minimizeButtonBadgeWarning = minimizeButton.children('.bg-warning')

          expect(minimizeButton.css('display')).not.toBe('none')

          minimizeButton.click()

          expect(minimizeButtonBadgeInfo.css('display')).not.toContain('none')
          expect(minimizeButtonBadgeInfo.text()).toBe('1')
          expect(minimizeButtonBadgeError.css('display')).toContain('none')
          expect(minimizeButtonBadgeWarning.css('display')).toContain('none')

          minimizeButton.click()
          const notification2 = notifier.notify('msg', 'error')
          notifier.notify('msg', 'warn')

          minimizeButton.click()
          expect(minimizeButtonBadgeInfo.css('display')).not.toContain('none')
          expect(minimizeButtonBadgeInfo.text()).toBe('1')
          expect(minimizeButtonBadgeError.css('display')).not.toContain('none')
          expect(minimizeButtonBadgeError.text()).toBe('1')
          expect(minimizeButtonBadgeWarning.css('display')).not.toContain('none')
          expect(minimizeButtonBadgeWarning.text()).toBe('1')

          minimizeButton.click()
          notification2.dismiss()

          minimizeButton.click()
          expect(minimizeButtonBadgeInfo.css('display')).not.toContain('none')
          expect(minimizeButtonBadgeInfo.text()).toBe('1')
          expect(minimizeButtonBadgeError.css('display')).toContain('none')
          expect(minimizeButtonBadgeWarning.css('display')).not.toContain('none')
          expect(minimizeButtonBadgeWarning.text()).toBe('1')

          done()
        } catch (error) {
          done(error)
        }
      })
    })
  })

  describe('notify', () => {
    test("displays a green notification when passed a message and level='info'", (done) => {
      const notificationMessage = "'Y$deH[|%ROii]jy"

      $(() => {
        try {
          notifier.notify(notificationMessage, 'info')

          const successMessages = notificationsElement.children('.messages').find('.success-notification')

          expect(successMessages.length).toBe(1)
          expect(successMessages[0].innerHTML).toContain(notificationMessage)
          done()
        } catch (error) {
          done(error)
        }
      })
    })

    test("displays a red notification when passed a message and level='error'", (done) => {
      const notificationMessage = '\\+!h0bbH"yN7dx9.'

      $(() => {
        try {
          notifier.notify(notificationMessage, 'error')

          const failureMessages = notificationsElement.find('.danger-notification')

          expect(failureMessages.length).toBe(1)
          expect(failureMessages[0].innerHTML).toContain(notificationMessage)
          done()
        } catch (error) {
          done(error)
        }
      })
    })

    test('displays the minimize button after no notifications were present before', (done) => {
      $(() => {
        try {
          const messageNotificationsContainer = notificationsElement.find('.messages')
          const minimizeButton = notificationsElement.find('#toggle-minimize-notifications')

          expect(minimizeButton.css('display')).toBe('none')
          expect(messageNotificationsContainer.children().length).toBe(0)

          notifier.notify('msg', 'info')

          expect(minimizeButton.css('display')).not.toBe('none')
          expect(messageNotificationsContainer.children().length).toBeGreaterThan(0)

          done()
        } catch (error) {
          done(error)
        }
      })
    })

    describe('when the notifier is minimized', () => {
      let minimizeButton

      beforeEach(() => {
        $(() => {
          minimizeButton = notificationsElement.find('#toggle-minimize-notifications')

          notifier.notify('msg', 'info')
          minimizeButton.click()
        })
      })

      test("un-hides the badge corresponding to the notification's level if it is the only notification with that level", (done) => {
        $(() => {
          try {
            const minimizeButtonBadgeError = notificationsElement.find('#toggle-minimize-notifications .bg-danger')

            expect(notificationsElement.children('.messages').css('display')).toBe('none')
            expect(minimizeButton.css('display')).not.toBe('none')
            expect(minimizeButtonBadgeError.css('display')).toBe('none')

            notifier.notify('msg', 'error')

            expect(minimizeButtonBadgeError.css('display')).not.toBe('none')

            done()
          } catch (error) {
            done(error)
          }
        })
      })

      test("increments the number on badge corresponding to the notification's level when the badge is already displayed", (done) => {
        $(() => {
          try {
            const minimizeButtonBadgeInfo = notificationsElement.find('#toggle-minimize-notifications .bg-success')

            expect(notificationsElement.children('.messages').css('display')).toBe('none')
            expect(minimizeButton.css('display')).not.toBe('none')
            expect(minimizeButtonBadgeInfo.css('display')).not.toBe('none')
            expect(minimizeButtonBadgeInfo.text()).toBe('1')

            notifier.notify('msg', 'info')

            expect(minimizeButtonBadgeInfo.text()).toBe('2')

            const minimizeButtonBadgeError = notificationsElement.find('#toggle-minimize-notifications .bg-danger')
            notifier.notify('msg', 'error')

            expect(minimizeButtonBadgeError.css('display')).not.toBe('none')
            expect(minimizeButtonBadgeError.text()).toBe('1')

            notifier.notify('msg', 'error')

            expect(minimizeButtonBadgeError.text()).toBe('2')

            const minimizeButtonBadgeWarning = notificationsElement.find('#toggle-minimize-notifications .bg-warning')
            notifier.notify('msg', 'warn')

            expect(minimizeButtonBadgeWarning.css('display')).not.toBe('none')
            expect(minimizeButtonBadgeWarning.text()).toBe('1')

            notifier.notify('msg', 'warn')

            expect(minimizeButtonBadgeWarning.text()).toBe('2')
            done()
          } catch (error) {
            done(error)
          }
        })
      })
    })

    test('appends a dismissable message to the notifications widget', (done) => {
      $(() => {
        try {
          notifier.notify('', 'error')
          notifier.notify('', 'info')

          const messagesContainer = notificationsElement.children('.messages')
          let failureMessages = messagesContainer.find('.danger-notification')
          let successMessages = messagesContainer.find('.success-notification')

          expect(failureMessages.length).toBe(1)
          expect(successMessages.length).toBe(1)

          failureMessages.children('button').click()
          failureMessages = notificationsElement.find('.danger-notification')

          expect(failureMessages.length).toBe(0)

          $(successMessages[0]).children('button').click()
          successMessages = notificationsElement.find('.success-notification')

          expect(successMessages.length).toBe(1)

          done()
        } catch (error) {
          done(error)
        }
      })
    })

    test('appends a non dismissable message to the notifications widget when message dismissable is turned off', (done) => {
      $(() => {
        try {
          notifier.notify('', 'error', false)

          let failureMessages = notificationsElement.find('.danger-notification')

          expect(failureMessages.length).toBe(1)

          failureMessages.children('button').click()
          failureMessages = notificationsElement.find('.danger-notification')

          expect(failureMessages.length).toBe(1)

          done()
        } catch (error) {
          done(error)
        }
      })
    })

    test('throws a RangeError when passed an unsupported message level', (done) => {
      $(() => {
        try {
          expect(() => {
            notifier.notify('message', 'unsupported level')
          }).toThrow(RangeError)

          done()
        } catch (error) {
          done(error)
        }
      })
    })

    test('throws a TypeError when param message is not a string', (done) => {
      $(() => {
        try {
          expect(() => {
            notifier.notify(6, 'info')
          }).toThrow(TypeError)

          done()
        } catch (error) {
          done(error)
        }
      })
    })

    test('returns a Notification object representing the new notification', (done) => {
      $(() => {
        try {
          const notification = notifier.notify('test', 'info')
          const onlyNotification = notificationsElement.children('.messages').children('.success-notification')
          expect(notification.notificationElement.is(onlyNotification)).toBe(true)

          done()
        } catch (error) {
          done(error)
        }
      })
    })
  })

  describe('resolveAsyncOperation', () => {
    test('displays the saved toast for 2 seconds when not passed an error', (done) => {
      $(() => {
        const savedToast = $('#async-success-indicator')

        try {
          notifier.waitForAsyncOperation()
          expect(savedToast.css('display')).toBe('none')

          setTimeout(() => {
            expect(savedToast.attr('style')).toEqual(expect.not.stringContaining('display: none'))
            done()
          }, 2000)

          notifier.resolveAsyncOperation()
          expect(savedToast.attr('style')).toEqual(expect.not.stringContaining('display: none'))
        } catch (error) {
          done(error)
        }
      })
    })

    test('displays the saved toast for 2 seconds after the last call in a quick succession of calls when not passed an error', (done) => {
      $(() => {
        const savedToast = $('#async-success-indicator')

        try {
          notifier.waitForAsyncOperation()
          notifier.waitForAsyncOperation()
          notifier.waitForAsyncOperation()
          expect(savedToast.css('display')).toBe('none')

          setTimeout(() => {
            expect(savedToast.attr('style')).toEqual(expect.not.stringContaining('display: none'))
            done()
          }, 4000)

          notifier.resolveAsyncOperation()
          expect(savedToast.attr('style')).toEqual(expect.not.stringContaining('display: none'))

          // call resolveAsyncOperation before the previous resolveAsyncOperation call dismisses the saved Toast
          setTimeout(() => {
            notifier.resolveAsyncOperation()
          }, 1000)

          setTimeout(() => {
            notifier.resolveAsyncOperation()
          }, 2000)
        } catch (error) {
          done(error)
        }
      })
    })

    test('displays a red notification when passed an error', (done) => {
      const errorMessage = 'hxDEe@no$~Bl%m^]'

      $(() => {
        try {
          notifier.waitForAsyncOperation()
          notifier.resolveAsyncOperation(errorMessage)

          const failureMessages = notificationsElement.find('.danger-notification')

          expect(failureMessages.length).toBe(1)
          expect(failureMessages[0].innerHTML).toContain(errorMessage)
          done()
        } catch (error) {
          done(error)
        }
      })
    })

    test('hides the loading toast when there are no more async operations to wait on', (done) => {
      $(() => {
        const loadingToast = $('#async-waiting-indicator')

        try {
          notifier.waitForAsyncOperation()
          notifier.waitForAsyncOperation()
          expect(loadingToast.attr('style')).toEqual(expect.not.stringContaining('display: none'))

          notifier.resolveAsyncOperation()
          notifier.resolveAsyncOperation()

          expect(loadingToast.css('display')).toBe('none')

          done()
        } catch (error) {
          done(error)
        }
      })
    })

    test('throws an error and display it in a red notification when trying to stop an async operation when it\'s sexpecting to resolve none', (done) => {
      $(() => {
        try {
          expect(() => {
            notifier.resolveAsyncOperation()
          }).toThrow()

          done()
        } catch (error) {
          done(error)
        }
      })
    })
  })

  describe('totalNotificationCount', () => {
    it('returns the number of notifications the notifier currently has displayed', (done) => {
      $(() => {
        try {
          expect(notifier.totalNotificationCount()).toBe(0)

          const notificationCount = Math.floor(Math.random() * 10) + 1
          const notifications = []

          for (let i = 0; i < notificationCount; i++) {
            notifications.push(notifier.notify('message', 'error'))
          }

          expect(notifier.totalNotificationCount()).toBe(notificationCount)

          const aboutHalfNotificationCount = Math.floor(notificationCount / 2)

          for (let i = 0; i < aboutHalfNotificationCount; i++) {
            notifications.pop().dismiss()
          }

          expect(notifier.totalNotificationCount()).toBe(notificationCount - aboutHalfNotificationCount)

          done()
        } catch (error) {
          done(error)
        }
      })
    })
  })

  describe('waitForAsyncOperation', () => {
    test('displays the loading indicator', (done) => {
      $(() => {
        const loadingToast = $('#async-waiting-indicator')

        try {
          expect(loadingToast.css('display')).toBe('none')

          notifier.waitForAsyncOperation()
          expect(loadingToast.attr('style')).toEqual(expect.not.stringContaining('display: none'))

          done()
        } catch (error) {
          done(error)
        }
      })
    })
  })
})

describe('Notifications', () => {
  let notification
  const notificationDefaultMessage = 'm*GV}.n?@D\\~]jW=JD$d'

  beforeEach(() => {
    $(() => {
      notification = notifier.notify(notificationDefaultMessage, 'warn')
    })
  })

  describe('constructor', () => {
    test('throws a TypeError when passed a non jQuery object', (done) => {
      $(() => {
        try {
          expect(() => {
            // eslint-disable-next-line no-new
            new Notification(3)
          }).toThrow(TypeError)
          done()
        } catch (error) {
          done(error)
        }
      })
    })

    test('throws a ReferenceError when passed jQuery object not representing anything in the dom', (done) => {
      $(() => {
        try {
          expect(() => {
            // eslint-disable-next-line no-new
            new Notification($('#non-existant-element'))
          }).toThrow(ReferenceError)
          done()
        } catch (error) {
          done(error)
        }
      })
    })
  })

  describe('dismiss', () => {
    test('removes the notification elements', (done) => {
      $(() => {
        try {
          expect(notificationsElement[0].innerHTML).toContain(notificationDefaultMessage)

          notification.dismiss()
          expect(notificationsElement[0].innerHTML).not.toContain(notificationDefaultMessage)
          done()
        } catch (error) {
          done(error)
        }
      })
    })

    test('should throw an error if the notification has already been dismissed', (done) => {
      $(() => {
        try {
          expect(notificationsElement[0].innerHTML).toContain(notificationDefaultMessage)

          notification.dismiss()
          expect(notificationsElement[0].innerHTML).not.toContain(notificationDefaultMessage)

          expect(() => {
            notification.dismiss()
          }).toThrow(ReferenceError)
          done()
        } catch (error) {
          done(error)
        }
      })
    })

    test('causes the notifier to hide the minimize button if it dismisses the last notification', (done) => {
      $(() => {
        try {
          expect(notificationsElement[0].innerHTML).toContain(notificationDefaultMessage)
          expect($('#toggle-minimize-notifications').css('display')).not.toContain('none')

          notification.dismiss()
          expect(notificationsElement[0].innerHTML).not.toContain(notificationDefaultMessage)
          expect($('#toggle-minimize-notifications').css('display')).toContain('none')
          done()
        } catch (error) {
          done(error)
        }
      })
    })

    test("hides the badge corresponding to the notification's level when there are no more notifications matching the dismissed notification's level", (done) => {
      $(() => {
        try {
          done()
        } catch (error) {
          done(error)
        }
      })
    })

    test('hides the minimize button if no notifications are left', (done) => {
      $(() => {
        try {
          done()
        } catch (error) {
          done(error)
        }
      })
    })

    test("decrements the number on badge corresponding to the notification's level when there are still notifications matching the dismissed notification's level left", (done) => {
      $(() => {
        try {
          done()
        } catch (error) {
          done(error)
        }
      })
    })
  })

  describe('getText', () => {
    test('should return the text of the notification', (done) => {
      $(() => {
        try {
          expect(notificationsElement[0].innerHTML).toContain(notificationDefaultMessage)
          expect(notification.getText()).toBe(notificationDefaultMessage)

          done()
        } catch (error) {
          done(error)
        }
      })
    })
  })

  describe('isUserDismissable', () => {
    test('returns a truthy value if there is a dismiss button, false otherwise', (done) => {
      $(() => {
        try {
          expect(notificationsElement[0].innerHTML).toContain(notificationDefaultMessage)
          expect(notification.isUserDismissable()).toBeTruthy()

          notification.notificationElement.children('button').remove()

          expect(notification.isUserDismissable()).not.toBeTruthy()
          done()
        } catch (error) {
          done(error)
        }
      })
    })
  })

  describe('isDismissed', () => {
    test('returns a falsy value if the notification could be found as a child of the notificatons component', (done) => {
      $(() => {
        try {
          expect($(document).find(notification.notificationElement).length).toBe(1)
          expect(notification.isDismissed()).not.toBeTruthy()
          done()
        } catch (error) {
          done(error)
        }
      })
    })

    test('returns a truthy value if the notification could not be found as a child of the notificatons component', (done) => {
      $(() => {
        try {
          expect($(document).find(notification.notificationElement).length).toBe(1)

          notification.notificationElement.remove()

          expect($(document).find(notification.notificationElement).length).toBe(0)
          expect(notification.isDismissed()).toBeTruthy()
          done()
        } catch (error) {
          done(error)
        }
      })
    })
  })

  describe('setUserDismissable', () => {
    test('adds a dismiss button that removes the notification element when clicked if one is not present', (done) => {
      $(() => {
        try {
          const notificationMessage = 'mn6#:6C^*hnQ/:cC;2mM'
          notification = notifier.notify(notificationMessage, 'info', false)

          expect(notificationsElement[0].innerHTML).toContain(notificationMessage)
          expect(notification.notificationElement.children('button').length).toBe(0)

          notification.setUserDismissable(true)

          expect(notification.notificationElement.children('button').length).toBe(1)

          notification.notificationElement.children('button').click()

          expect($(document).find(notification.notificationElement).length).toBe(0)
          done()
        } catch (error) {
          done(error)
        }
      })
    })

    test('does nothing if the notification is already in the desired state', (done) => {
      $(() => {
        try {
          expect(notificationsElement[0].innerHTML).toContain(notificationDefaultMessage)
          expect(notification.notificationElement.children('button').length).toBe(1)

          notification.setUserDismissable(true)

          expect(notification.notificationElement.children('button').length).toBe(1)

          const notificationMessage = 'fd@4g*G@.6sV{!^Yj*TR'
          notification = notifier.notify(notificationMessage, 'info', false)

          expect(notificationsElement[0].innerHTML).toContain(notificationMessage)
          expect(notification.notificationElement.children('button').length).toBe(0)

          notification.setUserDismissable(false)

          expect(notification.notificationElement.children('button').length).toBe(0)
          done()
        } catch (error) {
          done(error)
        }
      })
    })

    test('removes the dismiss button that removes the notification element when clicked if the button is present', (done) => {
      $(() => {
        try {
          expect(notificationsElement[0].innerHTML).toContain(notificationDefaultMessage)
          expect(notification.notificationElement.children('button').length).toBe(1)

          notification.setUserDismissable(false)

          expect(notification.notificationElement.children('button').length).toBe(0)
          done()
        } catch (error) {
          done(error)
        }
      })
    })

    test('throws an error if the notification is dismissed', (done) => {
      $(() => {
        try {
          notification.notificationElement.remove()
          expect(notificationsElement[0].innerHTML).not.toContain(notificationDefaultMessage)

          expect(() => {
            notification.setUserDismissable(true)
          }).toThrow(ReferenceError)
          done()
        } catch (error) {
          done(error)
        }
      })
    })
  })

  describe('setText', () => {
    test('changes the text of the notification', (done) => {
      $(() => {
        try {
          expect(notificationsElement[0].innerHTML).toContain(notificationDefaultMessage)

          const newNotificationMessage = 'VOr%%:#Vc*tbNbM}iUT}'

          notification.setText(newNotificationMessage)

          expect(notification.notificationElement.text()).toContain(newNotificationMessage)
          done()
        } catch (error) {
          done(error)
        }
      })
    })

    test('throws an error if the notification has been dismissed', (done) => {
      $(() => {
        try {
          notification.notificationElement.remove()
          expect(notificationsElement[0].innerHTML).not.toContain(notificationDefaultMessage)

          expect(() => {
            notification.setText('new Text')
          }).toThrow(ReferenceError)
          done()
        } catch (error) {
          done(error)
        }
      })
    })
  })

  describe('toggleUserDismissable', () => {
    test('will add a functioning dismiss button for the user if there is none', (done) => {
      $(() => {
        try {
          const notificationMessage = 'nm8j$<w*HszPHkObK._n'
          notification = notifier.notify(notificationMessage, 'info', false)

          expect(notificationsElement[0].innerHTML).toContain(escape(notificationMessage))
          expect(notification.notificationElement.children('button').length).toBe(0)

          notification.toggleUserDismissable()

          expect(notification.notificationElement.children('button').length).toBe(1)

          notification.notificationElement.children('button').click()

          expect($(document).find(notification.notificationElement).length).toBe(0)
          done()
        } catch (error) {
          done(error)
        }
      })
    })

    test('will remove the dismiss button for the user if is present', (done) => {
      $(() => {
        try {
          expect(notificationsElement[0].innerHTML).toContain(escape(notificationDefaultMessage))
          expect(notification.notificationElement.children('button').length).toBe(1)

          notification.toggleUserDismissable()

          expect(notification.notificationElement.children('button').length).toBe(0)
          done()
        } catch (error) {
          done(error)
        }
      })
    })

    test('throws an error if the notification has been dismissed', (done) => {
      $(() => {
        try {
          notification.notificationElement.remove()
          expect(notificationsElement[0].innerHTML).not.toContain(escape(notificationDefaultMessage))

          expect(() => {
            notification.toggleUserDismissable()
          }).toThrow(ReferenceError)
          done()
        } catch (error) {
          done(error)
        }
      })
    })
  })
})
