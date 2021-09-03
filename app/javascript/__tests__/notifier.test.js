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

  asyncNotificationsElement = $('#async-notifications')
  notifier = new Notifier(asyncNotificationsElement)
});

test('notify should display a green notification when passed a message and level=\'info\'', () => {
  expect(() => {
    $(() => {
      
    })
  }).not.toThrow()
})

test('notify should display a red notification when passed a message and level=\'error\'', () => {
})

test('notify should throw a RangeError when passed an unsupported message level', () => {
})

test('notify should throw a TypeError when param message is not a string', () => {
})
