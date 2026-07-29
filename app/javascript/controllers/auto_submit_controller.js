import { Controller } from '@hotwired/stimulus'

// Submits the form when a control changes (e.g. the table filter selects). Turbo Drive
// keeps the navigation smooth, so filtering has no full-page flash.
export default class extends Controller {
  submit () {
    this.element.requestSubmit()
  }
}
