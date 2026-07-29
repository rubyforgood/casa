/* eslint-env jest, browser */
/**
 * @jest-environment jsdom
 */
import { Application } from '@hotwired/stimulus'
import AddToCalendarController from '../controllers/add_to_calendar_controller'

describe('add_to_calendar_controller', () => {
  let application
  let capturedIcs
  let clicked

  const mount = async (html) => {
    document.body.innerHTML = html
    application = Application.start()
    application.register('add-to-calendar', AddToCalendarController)
    await new Promise((resolve) => setTimeout(resolve, 0))
  }

  beforeEach(() => {
    capturedIcs = null
    clicked = false
    const RealBlob = global.Blob
    jest.spyOn(global, 'Blob').mockImplementation((parts, opts) => {
      capturedIcs = parts[0]
      return new RealBlob(parts, opts)
    })
    global.URL.createObjectURL = jest.fn(() => 'blob:mock')
    global.URL.revokeObjectURL = jest.fn()
    jest.spyOn(HTMLAnchorElement.prototype, 'click').mockImplementation(() => { clicked = true })
  })

  afterEach(() => {
    if (application) application.stop()
    document.body.innerHTML = ''
    jest.restoreAllMocks()
  })

  test('downloads an .ics event built from the court-date values', async () => {
    await mount(`
      <button data-controller='add-to-calendar'
              data-action='add-to-calendar#download'
              data-add-to-calendar-title-value='Court Date CINA-1'
              data-add-to-calendar-start-value='2025-11-15'
              data-add-to-calendar-end-value='2025-11-15'>Add to calendar</button>
    `)

    document.querySelector('button').click()

    expect(clicked).toBe(true)
    expect(global.URL.createObjectURL).toHaveBeenCalled()
    expect(capturedIcs).toContain('BEGIN:VCALENDAR')
    expect(capturedIcs).toContain('SUMMARY:Court Date CINA-1')
    expect(capturedIcs).toContain('DTSTART;VALUE=DATE:20251115')
    expect(capturedIcs).toContain('DTEND;VALUE=DATE:20251116')
    expect(capturedIcs).toContain('END:VEVENT')
  })
})
