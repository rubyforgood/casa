import { Controller } from '@hotwired/stimulus'

// Progressive disclosure for a collapsible panel (e.g. the Change Password /
// Change Email sections on the edit-profile page). The panel starts hidden and
// the trigger button toggles it.
export default class extends Controller {
  static targets = ['panel', 'trigger']

  toggle () {
    const hidden = this.panelTarget.classList.toggle('hidden')

    if (this.hasTriggerTarget) {
      this.triggerTarget.setAttribute('aria-expanded', String(!hidden))
    }
  }
}
