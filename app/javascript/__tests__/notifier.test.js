/* eslint-env jest */

require('jest')
const $ = require('jquery')
const Notifier = require('../src/async_notifier.js')

let asyncNotificationsElement
let notifier

beforeEach(() => {
  document.body.innerHTML =
    `<div id="async-notifications">
      <div id="async-waiting-indicator" style="display: none">
        Saving <div class="load-spinner"></div>
      </div>
      <div id="async-success-indicator" class="async-success-indicator" style="display: none">
        Saved
      </div>
    </div>`

  $(() => {
    asyncNotificationsElement = $('#async-notifications')
    notifier = new Notifier(asyncNotificationsElement)
  })
})

test('notify should display a green notification when passed a message and level=\'info\'', done => {
  const notificationMessage = '\'Y$deH[|%ROii]jy'

  $(() => {
    notifier.notify(notificationMessage, 'info')

    try {
      const successMessages = asyncNotificationsElement.find('.async-success-indicator')

      // Notifications contain the "Saved" message and the new message
      expect(successMessages.length).toBe(2)
      expect(asyncNotificationsElement.find('.async-success-indicator')[1].innerHTML).toContain(notificationMessage)
      done()
    } catch (error) {
      done(error)
    }
  })
})

test('notify should display a red notification when passed a message and level=\'error\'', () => {
})

test('notify should throw a RangeError when passed an unsupported message level', () => {
})

test('notify should throw a TypeError when param message is not a string', () => {
})
