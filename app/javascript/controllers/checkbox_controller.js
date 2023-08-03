import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = [ "checkbox" ]
  static values = { checked: Boolean }

  connect() {
    this.checked = this.hasCheckboxTarget && this.checkboxTarget.checked
  }

  toggle(e) {
    this.checked = !this.checked
    this.dispatch("toggle", { detail: { content: this.checkboxTarget.value } });
  }
}
