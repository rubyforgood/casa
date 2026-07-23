import { Controller } from '@hotwired/stimulus'
import TomSelect from 'tom-select'

// Single-select, searchable TomSelect for a native <select> (the court-report case picker).
// The default text search covers the option labels, which embed the assigned volunteer names,
// so supervisors/admins can find a case by volunteer. Connects to
// data-controller="searchable-select".
export default class extends Controller {
  // Values:
  //   dropdown-parent-value="body" -> render the menu on <body> (escape an overflow container)
  //   placeholder-value="..."      -> empty-state text shown when nothing is selected
  //   toggle-submit-value          -> disable the form's submit button until an option is picked
  static values = { dropdownParent: String, placeholder: String, toggleSubmit: Boolean }

  connect () {
    const options = {
      maxItems: 1,
      // With a placeholder (a blank-load picker) the empty <option> must NOT become a selected item --
      // TomSelect would then hide the input (and its placeholder) off-screen and show the empty item.
      // Court-report (no placeholder) keeps the default so its prompt option works.
      allowEmptyOption: !this.placeholderValue,
      dropdownParent: this.dropdownParentValue || null,
      plugins: { clear_button: { title: 'Clear selection' } }
    }
    if (this.placeholderValue) options.placeholder = this.placeholderValue
    this.select = new TomSelect(this.element, options)

    if (this.toggleSubmitValue) {
      this.submitButton = this.element.closest('form')?.querySelector('[type="submit"]')
      this.toggleSubmit()
      this.select.on('change', () => this.toggleSubmit())
    }
  }

  toggleSubmit () {
    if (this.submitButton) this.submitButton.disabled = !this.element.value
  }

  disconnect () {
    if (this.select) {
      this.select.destroy()
      this.select = null
    }
  }
}
