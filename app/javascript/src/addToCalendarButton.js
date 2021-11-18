import * as Add2Calendar from 'add2calendar'
import 'add2calendar/css/add2calendar.css'

function createCalendarEvents () {
  const calendarButtons = document.querySelectorAll('div.cal-btn')
  if (!calendarButtons) return
  console.log(calendarButtons)
  calendarButtons.forEach((btn) => {
    const calendarEvent = new Add2Calendar({
      title: btn.dataset.title,
      start: btn.dataset.date,
      end: btn.dataset.date,
      description: btn.dataset.title,
      isAllDay: true
    })

    console.log(btn.id)

    calendarEvent.createWidget(`#${btn.id}`)
  })
}

$('document').ready(() => {
  createCalendarEvents()
})
