import * as Add2Calendar from 'add2calendar'
import 'add2calendar/css/add2calendar.css'

function createCalendarEvents () {
  const calendarButtons = document.querySelectorAll('div.cal-btn')
  if (!calendarButtons) return
  calendarButtons.forEach((btn) => {
    const calendarEvent = new Add2Calendar({
      title: btn.dataset.title,
      start: btn.dataset.date,
      end: btn.dataset.date,
      description: btn.dataset.title,
      isAllDay: true
    })

    calendarEvent.createWidget(`#${btn.id}`)
    btn.title = btn.dataset.tooltip
  })
}

$('document').ready(() => {
  createCalendarEvents()
})
