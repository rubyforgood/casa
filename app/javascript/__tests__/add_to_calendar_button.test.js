/* eslint-env jest */
/**
 * @jest-environment jsdom
 */

require('jest')

// Mock the add-to-calendar-button module
jest.mock('add-to-calendar-button', () => ({}))

describe('add_to_calendar_button', () => {
  let mockJQuery

  beforeEach(() => {
    // Clear the document body
    document.body.innerHTML = ''

    // Mock jQuery
    mockJQuery = jest.fn((callback) => {
      if (typeof callback === 'function') {
        callback()
      }
    })
    global.$ = mockJQuery
  })

  afterEach(() => {
    jest.resetModules()
    delete global.$
  })

  const createCalendarButton = (dataset = {}) => {
    const div = document.createElement('div')
    div.className = 'cal-btn'
    Object.assign(div.dataset, {
      title: 'Court Hearing',
      start: '2025-11-15',
      end: '2025-11-15',
      tooltip: 'Add to calendar',
      ...dataset
    })
    return div
  }

  describe('createCalendarEvents', () => {
    test('creates add-to-calendar-button elements for all cal-btn divs', () => {
      // Setup
      const calBtn1 = createCalendarButton()
      const calBtn2 = createCalendarButton({
        title: 'Court Date 2',
        start: '2025-12-01',
        end: '2025-12-01'
      })
      document.body.appendChild(calBtn1)
      document.body.appendChild(calBtn2)

      // Execute
      require('../src/add_to_calendar_button')

      // Verify
      const buttons = document.querySelectorAll('add-to-calendar-button')
      expect(buttons.length).toBe(2)
    })

    test('sets correct attributes on the calendar button', () => {
      // Setup
      const calBtn = createCalendarButton({
        title: 'Important Meeting',
        start: '2025-11-20',
        end: '2025-11-20',
        tooltip: 'Add this event'
      })
      document.body.appendChild(calBtn)

      // Execute
      require('../src/add_to_calendar_button')

      // Verify
      const button = document.querySelector('add-to-calendar-button')
      expect(button.getAttribute('name')).toBe('Important Meeting')
      expect(button.getAttribute('startDate')).toBe('2025-11-20')
      expect(button.getAttribute('endDate')).toBe('2025-11-20')
      expect(button.getAttribute('description')).toBe('Important Meeting')
      expect(button.getAttribute('options')).toBe("'Apple','Google','iCal','Microsoft365','Outlook.com','Yahoo'")
      expect(button.getAttribute('timeZone')).toBe('currentBrowser')
      expect(button.getAttribute('lightMode')).toBe('bodyScheme')
      expect(button.title).toBe('Add this event')
    })

    test('clears existing content in cal-btn div', () => {
      // Setup
      const calBtn = createCalendarButton()
      calBtn.innerHTML = '<p>Old content</p>'
      document.body.appendChild(calBtn)

      // Execute
      require('../src/add_to_calendar_button')

      // Verify
      const oldContent = calBtn.querySelector('p')
      expect(oldContent).toBeNull()
      const button = calBtn.querySelector('add-to-calendar-button')
      expect(button).not.toBeNull()
    })

    test('handles empty dataset gracefully', () => {
      // Setup
      const div = document.createElement('div')
      div.className = 'cal-btn'
      document.body.appendChild(div)

      // Execute
      require('../src/add_to_calendar_button')

      // Verify
      const button = document.querySelector('add-to-calendar-button')
      expect(button).not.toBeNull()
      expect(button.getAttribute('name')).toBe('undefined')
      expect(button.getAttribute('startDate')).toBe('undefined')
      expect(button.getAttribute('endDate')).toBe('undefined')
    })

    test('does nothing when no cal-btn elements exist', () => {
      // Setup
      document.body.innerHTML = '<div class="other-content"></div>'

      // Execute
      require('../src/add_to_calendar_button')

      // Verify
      const buttons = document.querySelectorAll('add-to-calendar-button')
      expect(buttons.length).toBe(0)
    })

    test('calls createCalendarEvents on DOM ready', () => {
      // Setup
      const calBtn = createCalendarButton()
      document.body.appendChild(calBtn)

      // Execute
      require('../src/add_to_calendar_button')

      // Verify jQuery was called
      expect(mockJQuery).toHaveBeenCalled()
      expect(mockJQuery).toHaveBeenCalledWith(expect.any(Function))

      // Verify the calendar button was created
      const button = document.querySelector('add-to-calendar-button')
      expect(button).not.toBeNull()
    })

    test('preserves cal-btn class on parent div', () => {
      // Setup
      const calBtn = createCalendarButton()
      document.body.appendChild(calBtn)

      // Execute
      require('../src/add_to_calendar_button')

      // Verify
      const divs = document.querySelectorAll('div.cal-btn')
      expect(divs.length).toBe(1)
      expect(divs[0].querySelector('add-to-calendar-button')).not.toBeNull()
    })
  })
})
