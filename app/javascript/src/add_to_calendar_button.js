/* global $ */

import 'add-to-calendar-button'

function createCalendarEvents () {
  const calendarButtons = document.querySelectorAll('div.cal-btn')

  for (const calendarButton of calendarButtons) {
    // Create the add-to-calendar-button web component
    const button = document.createElement('add-to-calendar-button')

    // Set attributes from data attributes
    button.setAttribute('name', calendarButton.dataset.title)
    button.setAttribute('startDate', calendarButton.dataset.start)
    button.setAttribute('endDate', calendarButton.dataset.end)
    button.setAttribute('description', calendarButton.dataset.title)
    button.setAttribute('options', "'Apple','Google','iCal','Microsoft365','Outlook.com','Yahoo'")
    button.setAttribute('timeZone', 'currentBrowser')
    button.setAttribute('lightMode', 'bodyScheme')

    // Set tooltip
    button.title = calendarButton.dataset.tooltip

    // Replace the div content with the button
    calendarButton.innerHTML = ''
    calendarButton.appendChild(button)
  }
}

$(() => { // JQuery's callback for the DOM loading
  createCalendarEvents()
})
