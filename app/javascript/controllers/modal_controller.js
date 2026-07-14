import { Controller } from '@hotwired/stimulus'

// A modal built on the native <dialog> element. `open` calls showModal(), which
// traps focus, wires Escape-to-close, and makes the background inert; `close`
// closes it; a click on the backdrop (the <dialog> itself, outside its panel)
// also closes it. No custom focus-trap or key handling to maintain.
export default class extends Controller {
  static targets = ['dialog']
  static values = { openOnConnect: Boolean }

  connect () {
    if (this.openOnConnectValue) this.open()
  }

  open () {
    this.dialogTarget.showModal()
  }

  close () {
    this.dialogTarget.close()
  }

  backdropClose (event) {
    if (event.target === this.dialogTarget) {
      this.close()
    }
  }
}
