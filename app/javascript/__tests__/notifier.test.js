/* eslint-env jest */

require('jest')
const Notifier = require('../src/notifier.js')

let notificationsElement
let notifier

beforeEach(() => {
  document.body.innerHTML = `<div id="notifications">
      <div id="async-waiting-indicator" style="display: none">
        Saving <div class="load-spinner"></div>
      </div>
      <div id="async-success-indicator" class="async-success-indicator" style="display: none">
        Saved
      </div>
    </div>`

  $(document).ready(() => {
    notificationsElement = $('#notifications')
    notifier = new Notifier(notificationsElement)
  })
})

describe('notify', () => {
  test("notify should display a green notification when passed a message and level='info'", (done) => {
    const notificationMessage = "'Y$deH[|%ROii]jy"

    $(document).ready(() => {
      try {
        notifier.notify(notificationMessage, 'info')

        const successMessages = notificationsElement.find('.async-success-indicator')

        // Notifications contain the "Saved" message and the new message
        expect(successMessages.length).toBe(2)
        expect(successMessages[1].innerHTML).toContain(notificationMessage)
        done()
      } catch (error) {
        done(error)
      }
    })
  })

  test("notify should display a red notification when passed a message and level='error'", (done) => {
    const notificationMessage = '\\+!h0bbH"yN7dx9.'

    $(document).ready(() => {
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

  test('notify should append a dismissable message to the notifications widget', (done) => {
    $(document).ready(() => {
      try {
        notifier.notify('', 'error')
        notifier.notify('', 'info')

        let failureMessages = notificationsElement.find('.failure-indicator')
        let successMessages = notificationsElement.find('.async-success-indicator')

        expect(failureMessages.length).toBe(1)
        expect(successMessages.length).toBe(2)

        failureMessages.children('button').click()
        failureMessages = notificationsElement.find('.failure-indicator')

        expect(failureMessages.length).toBe(0)

        $(successMessages[1]).children('button').click()
        successMessages = notificationsElement.find('.async-success-indicator')

        expect(successMessages.length).toBe(1)

        done()
      } catch (error) {
        done(error)
      }
    })
  })

  test('notify should throw a RangeError when passed an unsupported message level', (done) => {
    $(document).ready(() => {
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

  test('notify should throw a TypeError when param message is not a string', (done) => {
    $(document).ready(() => {
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
})

describe('waitForAsyncOperation', () => {
  test('waitForAsyncOperation should display the loading indicator', (done) => {
    $(document).ready(() => {
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

describe('resolveAsyncOperation', () => {
  test('resolveAsyncOperation should display the saved toast for 2 seconds when not passed an error', (done) => {
    $(document).ready(() => {
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

  test('resolveAsyncOperation should display the saved toast for 2 seconds after the last call in a quick succession of calls when not passed an error', (done) => {
    $(document).ready(() => {
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

  test('resolveAsyncOperation should display a red notification when passed an error', (done) => {
    const errorMessage = 'hxDEe@no$~Bl%m^]'

    $(document).ready(() => {
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

  test('resolveAsyncOperation should hide the loading toast when there are no more async operations to wait on', (done) => {
    $(document).ready(() => {
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

  test('resolveAsyncOperation should throw an error and display it in a red notification when trying to stop an async operation when it\'s sexpecting to resolve none', (done) => {
    $(document).ready(() => {
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
