import { Controller } from '@hotwired/stimulus'
import TomSelect from 'tom-select'

// Single-select, searchable TomSelect for a native <select> (the court-report case picker).
// The default text search covers the option labels, which embed the assigned volunteer names,
// so supervisors/admins can find a case by volunteer. Connects to
// data-controller="searchable-select".
export default class extends Controller {
  connect () {
    this.select = new TomSelect(this.element, {
      maxItems: 1,
      allowEmptyOption: true
    })
  }

  disconnect () {
    if (this.select) {
      this.select.destroy()
      this.select = null
    }
  }
}
