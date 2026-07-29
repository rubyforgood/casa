import { Controller } from '@hotwired/stimulus'

// "Add to calendar": builds an .ics file from the court-date values and downloads
// it on click, so a court date imports into any calendar (Google, Apple, Outlook).
// Replaces the third-party <add-to-calendar-button> web component, whose own button
// styling did not match the design system; the trigger is now a ghost button.
export default class extends Controller {
  static values = { title: String, start: String, end: String }

  download (event) {
    event.preventDefault()
    const compact = (d) => d.replace(/-/g, '')
    // DTEND is exclusive for all-day events, so add a day to the inclusive end date.
    const end = new Date(`${this.endValue}T00:00:00`)
    end.setDate(end.getDate() + 1)
    const dtEnd = `${end.getFullYear()}${String(end.getMonth() + 1).padStart(2, '0')}${String(end.getDate()).padStart(2, '0')}`
    const stamp = new Date().toISOString().replace(/[-:]/g, '').split('.')[0] + 'Z'
    const ics = [
      'BEGIN:VCALENDAR',
      'VERSION:2.0',
      'PRODID:-//CASA//Court Date//EN',
      'BEGIN:VEVENT',
      `UID:${Date.now()}-${Math.random().toString(36).slice(2)}@casa`,
      `DTSTAMP:${stamp}`,
      `DTSTART;VALUE=DATE:${compact(this.startValue)}`,
      `DTEND;VALUE=DATE:${dtEnd}`,
      `SUMMARY:${this.titleValue}`,
      'END:VEVENT',
      'END:VCALENDAR'
    ].join('\r\n')
    const url = URL.createObjectURL(new Blob([ics], { type: 'text/calendar;charset=utf-8' }))
    const link = document.createElement('a')
    link.href = url
    link.download = `${this.titleValue.replace(/[^a-z0-9]+/gi, '-').toLowerCase()}.ics`
    document.body.appendChild(link)
    link.click()
    link.remove()
    URL.revokeObjectURL(url)
  }
}
