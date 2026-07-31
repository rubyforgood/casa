import { Controller } from '@hotwired/stimulus'

const DEBOUNCE_MS = 350
// Turbo Drive is disabled app-wide (application.js: `Turbo.session.drive = false`), so submitting
// this form is a real page load: in-memory state does not survive it, and the caret has to be parked
// somewhere that does. Verified -- a marker set on `window` before the submit is gone afterwards.
const FOCUS_KEY = 'auto-submit:focus'

// Submits the form when a control changes (the table filter selects), and searches as the user types
// in a search field.
export default class extends Controller {
  connect () {
    const parked = window.sessionStorage.getItem(FOCUS_KEY)
    if (!parked) return
    window.sessionStorage.removeItem(FOCUS_KEY)

    let position
    try {
      position = JSON.parse(parked)
    } catch {
      return
    }
    const field = this.element.querySelector(`[name="${position.name}"]`)
    if (!field) return

    // Deferred a frame so the restore lands after the browser has finished settling the new page.
    window.requestAnimationFrame(() => {
      field.focus()
      // Put the caret back, or every submit bounces it to the start of the box mid-word.
      if (field.setSelectionRange) field.setSelectionRange(position.start, position.end)
    })
  }

  submit () {
    this.element.requestSubmit()
  }

  // A text input fires `change` only on blur or Enter, so on a change-only filter bar typing looked
  // like it did nothing -- and the still-unsubmitted text then applied itself the moment the user
  // touched any other filter, which reads as the search box "keeping" letters it should not have.
  // Debounced: submit once the user pauses, not per keystroke.
  search (event) {
    const field = event.target
    window.sessionStorage.setItem(FOCUS_KEY, JSON.stringify({
      name: field.name, start: field.selectionStart, end: field.selectionEnd
    }))
    clearTimeout(this.timer)
    this.timer = setTimeout(() => this.submit(), DEBOUNCE_MS)
  }

  // A pending debounce must not outlive a deliberate navigation away -- the "Clear search" link.
  // Turbo Drive is off, so the click starts a real page load that does not tear this controller down
  // immediately: the timer fires during the unload and re-submits the query the user just cleared,
  // and that submit wins. Cancel the timer, and the parked caret with it (after a reset there is no
  // typing position worth restoring).
  cancel () {
    clearTimeout(this.timer)
    window.sessionStorage.removeItem(FOCUS_KEY)
  }

  disconnect () {
    clearTimeout(this.timer)
  }
}
