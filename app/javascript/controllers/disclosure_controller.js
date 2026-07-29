import { Controller } from '@hotwired/stimulus'

// Progressive disclosure for a collapsible panel (e.g. the Change Password /
// Change Email sections on the edit-profile page). The panel starts hidden and
// the trigger button toggles it.
export default class extends Controller {
  static targets = ['panel', 'trigger', 'field']

  toggle () {
    const hidden = this.panelTarget.classList.toggle('hidden')

    if (this.hasTriggerTarget) {
      this.triggerTarget.setAttribute('aria-expanded', String(!hidden))
    }

    // Optional `field` target: a hidden input that carries the open state through a form submit.
    // Without it, a panel inside a form that re-renders (an auto-submitting filter bar, or a
    // validation failure) has its state re-derived server-side and snaps shut under the user.
    if (this.hasFieldTarget) {
      this.fieldTarget.value = hidden ? '' : '1'
    }
  }
}
