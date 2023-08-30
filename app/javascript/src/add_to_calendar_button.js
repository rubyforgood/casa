/* global $ */

const Add2Calendar = require('add2calendar')

function createCalendarEvents () {
  const calendarButtons = document.querySelectorAll('div.cal-btn')
  if (!calendarButtons) return
  calendarButtons.forEach((btn) => {
    const calendarEvent = new Add2Calendar({
      title: btn.dataset.title,
      start: btn.dataset.start,
      end: btn.dataset.end,
      description: btn.dataset.title,
      isAllDay: true
    })

    calendarEvent.createWidget(`#${btn.id}`)
    btn.title = btn.dataset.tooltip
  })
}

$(() => { // JQuery's callback for the DOM loading
  createCalendarEvents()
})
