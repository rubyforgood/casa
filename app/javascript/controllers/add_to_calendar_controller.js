import { Controller } from '@hotwired/stimulus'
import 'add-to-calendar-button'

// Hydrates an "Add to Calendar" web component from data values, so a court date
// (or the next court date) can be saved to a personal calendar. This is the
// Stimulus replacement for the legacy jQuery `div.cal-btn` scan
// (src/add_to_calendar_button.js): it hydrates on connect, so it also survives
// Turbo navigation, and each button owns its own data instead of a global sweep.
export default class extends Controller {
  static values = {
    title: String,
    start: String,
    end: String,
    tooltip: String
  }

  connect () {
    const button = document.createElement('add-to-calendar-button')
    button.setAttribute('name', this.titleValue)
    button.setAttribute('startDate', this.startValue)
    button.setAttribute('endDate', this.endValue)
    button.setAttribute('description', this.titleValue)
    button.setAttribute('options', "'Apple','Google','iCal','Microsoft365','Outlook.com','Yahoo'")
    button.setAttribute('timeZone', 'currentBrowser')
    button.setAttribute('lightMode', 'bodyScheme')
    button.title = this.tooltipValue
    this.element.replaceChildren(button)
  }
}
