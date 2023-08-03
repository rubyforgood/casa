import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = [ "checkbox" ]
  static values = { checked: Boolean }

  connect() {
    this.checked = this.hasCheckboxTarget && this.checkboxTarget.checked
    console.log(`Checkbox is ${this.checked}`)
  }

  toggle() {
    this.checked = !this.checked
    console.log(`Checkbox is ${this.checked}`)
  }
}
