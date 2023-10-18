/* eslint-env jest */
import { escape } from 'lodash'

require('jest')
const { Notifier, Notification } = require('../src/notifier.js')

let notificationsElement
let notifier

beforeEach(() => {
  document.body.innerHTML = `<div id="notifications">
      <div id="async-waiting-indicator" style="display: none">
        Saving <div class="load-spinner"></div>
      </div>
      <div id="async-success-indicator" class="success-indicator" style="display: none">
        Saved
      </div>
      <button id="toggle-minimize-notifications" style="display: none;">minimize notifications <i class="fa-solid fa-minus"></i></button>
    </div>`

  $(() => { // JQuery's callback for the DOM loading
    notificationsElement = $('#notifications')
    notifier = new Notifier(notificationsElement)
  })
})

describe('Notifier', () => {
  describe('notify', () => {
    test("displays a green notification when passed a message and level='info'", (done) => {
      const notificationMessage = "'Y$deH[|%ROii]jy"

      $(() => {
        try {
          notifier.notify(notificationMessage, 'info')

          const successMessages = notificationsElement.find('.success-indicator')

          // Notifications contain the hidden "Saved" message and the new message
          expect(successMessages.length).toBe(2)
          expect(successMessages[1].innerHTML).toContain(notificationMessage)
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

          const failureMessages = notificationsElement.find('.failure-indicator')

          expect(failureMessages.length).toBe(1)
          expect(failureMessages[0].innerHTML).toContain(notificationMessage)
          done()
        } catch (error) {
          done(error)
        }
      })
    })

    test('appends a dismissable message to the notifications widget', (done) => {
      $(() => {
        try {
          notifier.notify('', 'error')
          notifier.notify('', 'info')

          let failureMessages = notificationsElement.find('.failure-indicator')
          let successMessages = notificationsElement.find('.success-indicator')

          expect(failureMessages.length).toBe(1)
          expect(successMessages.length).toBe(2)

          failureMessages.children('button').click()
          failureMessages = notificationsElement.find('.failure-indicator')

          expect(failureMessages.length).toBe(0)

          $(successMessages[1]).children('button').click()
          successMessages = notificationsElement.find('.success-indicator')

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

          let failureMessages = notificationsElement.find('.failure-indicator')

          expect(failureMessages.length).toBe(1)

          failureMessages.children('button').click()
          failureMessages = notificationsElement.find('.failure-indicator')

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
          const onlyNotification = notificationsElement.children('.success-indicator')
          expect(notification.notificationElement.is(onlyNotification)).toBe(true)

          done()
        } catch (error) {
          done(error)
        }
      })
    })
  })

  describe('notificationsCount', () => {
    it('automatically shows the minimize button when going from 0 to 1 notifications', (done) => {
      $(() => {
        try {
        } catch (error) {
          done(error)
        }
      })
    })

    it('automatically hides the minimize button when going from 1 to 0 notifications', (done) => {
      $(() => {
        try {
        } catch (error) {
          done(error)
        }
      })
    })

    it('increments the correct', (done) => {
      $(() => {
        try {
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

          const failureMessages = notificationsElement.find('.failure-indicator')

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

  describe('setMinimizeButtonVisibility', () => {
    it('hides the mimimize button when passed false', (done) => {
      $(() => {
        try {
        } catch (error) {
          done(error)
        }
      })
    })

    it('shows the mimimize button when passed true', (done) => {
      $(() => {
        try {
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
