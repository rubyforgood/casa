import { Controller } from '@hotwired/stimulus'
import TomSelect from 'tom-select'

// Single-select, searchable TomSelect for a native <select> (the court-report case picker).
// The default text search covers the option labels, which embed the assigned volunteer names,
// so supervisors/admins can find a case by volunteer. Connects to
// data-controller="searchable-select".
export default class extends Controller {
  // Pass data-searchable-select-dropdown-parent-value="body" when the <select> is inside an overflow
  // container (e.g. a table with overflow-x-auto) so the menu renders on <body> and isn't clipped.
  static values = { dropdownParent: String }

  connect () {
    this.select = new TomSelect(this.element, {
      maxItems: 1,
      allowEmptyOption: true,
      dropdownParent: this.dropdownParentValue || null
    })
  }

  disconnect () {
    if (this.select) {
      this.select.destroy()
      this.select = null
    }
  }
}
