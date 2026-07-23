/* eslint-env jest */
/**
 * @jest-environment jsdom
 */
import { Application } from '@hotwired/stimulus'
import AddToCalendarController from '../controllers/add_to_calendar_controller'

// The web component itself is browser-only; stub it out so importing the
// controller has no side effects and createElement makes an inert element.
jest.mock('add-to-calendar-button', () => ({}))

describe('add_to_calendar_controller', () => {
  let application

  const mount = async (html) => {
    document.body.innerHTML = html
    application = Application.start()
    application.register('add-to-calendar', AddToCalendarController)
    await new Promise((resolve) => setTimeout(resolve, 0))
  }

  afterEach(() => {
    if (application) application.stop()
    document.body.innerHTML = ''
  })

  test('replaces its content with a configured add-to-calendar-button', async () => {
    await mount(`
      <div data-controller="add-to-calendar"
           data-add-to-calendar-title-value="Court Hearing"
           data-add-to-calendar-start-value="2025-11-15"
           data-add-to-calendar-end-value="2025-11-15"
           data-add-to-calendar-tooltip-value="Add to calendar">stale content</div>
    `)

    const host = document.querySelector('[data-controller="add-to-calendar"]')
    const button = host.querySelector('add-to-calendar-button')

    expect(button).not.toBeNull()
    expect(host.textContent).not.toContain('stale content')
    expect(button.getAttribute('name')).toBe('Court Hearing')
    expect(button.getAttribute('startDate')).toBe('2025-11-15')
    expect(button.getAttribute('endDate')).toBe('2025-11-15')
    expect(button.getAttribute('description')).toBe('Court Hearing')
    expect(button.getAttribute('options')).toBe("'Apple','Google','iCal','Microsoft365','Outlook.com','Yahoo'")
    expect(button.getAttribute('timeZone')).toBe('currentBrowser')
    expect(button.getAttribute('lightMode')).toBe('bodyScheme')
    expect(button.title).toBe('Add to calendar')
  })
})
