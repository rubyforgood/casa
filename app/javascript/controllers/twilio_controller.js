import { Controller } from '@hotwired/stimulus'

// Reveals the Twilio credential fields when "Enable Twilio" is checked, and flips their
// required/disabled so the browser only validates + submits them while enabled. Replaces the
// jQuery + Bootstrap-collapse twilioToggle (src/casa_org.js) on the casa_app settings page.
// Connects to data-controller="twilio".
export default class extends Controller {
  static targets = ['checkbox', 'panel', 'field']

  connect () {
    this.toggle()
  }

  toggle () {
    const enabled = this.checkboxTarget.checked
    this.panelTarget.classList.toggle('hidden', !enabled)
    this.fieldTargets.forEach((field) => {
      field.required = enabled
      field.disabled = !enabled
      field.setAttribute('aria-required', String(enabled))
      field.setAttribute('aria-disabled', String(!enabled))
    })
  }
}
