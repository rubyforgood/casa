/* global $ */

const Add2Calendar = require('add2calendar')

function createCalendarEvents () {
  const calendarButtons = document.querySelectorAll('div.cal-btn')

  for (const calendarButton of calendarButtons) {
    const calendarEvent = new Add2Calendar({
      title: calendarButton.dataset.title,
      start: calendarButton.dataset.start,
      end: calendarButton.dataset.end,
      description: calendarButton.dataset.title,
      isAllDay: true
    })

    calendarEvent.createWidget(`#${calendarButton.id}`)
    calendarButton.title = calendarButton.dataset.tooltip
  }
}

$(() => { // JQuery's callback for the DOM loading
  createCalendarEvents()
})
