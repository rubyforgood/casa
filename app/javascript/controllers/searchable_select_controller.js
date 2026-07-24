import { Controller } from '@hotwired/stimulus'
import TomSelect from 'tom-select'

// Single-select, searchable TomSelect for a native <select> (the court-report case picker + the
// supervisors-index per-row assign). The default text search covers the option labels, which embed
// the assigned volunteer names, so supervisors/admins can find a case by volunteer. Connects to
// data-controller="searchable-select".
export default class extends Controller {
  // Values:
  //   dropdown-parent-value="body" -> render the menu on <body> (escape an overflow container)
  //   placeholder-value="..."      -> empty-state text shown when nothing is selected
  //   toggle-submit-value          -> validate on submit: if nothing is picked, block the submit,
  //                                   reveal the form's [data-searchable-select-error], and refocus
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
      this.form = this.element.closest('form')
      this.guard = this.guard.bind(this)
      if (this.form) this.form.addEventListener('submit', this.guard)
      this.select.on('change', () => { if (this.element.value) this.hideError() })
    }
  }

  guard (event) {
    if (!this.element.value) {
      event.preventDefault()
      event.stopPropagation()
      const error = this.errorElement()
      if (error) error.classList.remove('hidden')
      if (this.select) this.select.focus()
    }
  }

  hideError () {
    const error = this.errorElement()
    if (error) error.classList.add('hidden')
  }

  errorElement () {
    return this.form ? this.form.querySelector('[data-searchable-select-error]') : null
  }

  disconnect () {
    if (this.form && this.guard) this.form.removeEventListener('submit', this.guard)
    if (this.select) {
      this.select.destroy()
      this.select = null
    }
  }
}
