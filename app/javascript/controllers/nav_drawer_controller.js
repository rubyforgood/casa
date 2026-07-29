import { Controller } from '@hotwired/stimulus'

// Mobile navigation drawer for the casa_app + all_casa_admin shells. Below the
// `lg` breakpoint the sidebar is off-canvas (translated -100%); this toggles it
// in/out with a dimmed backdrop and locks body scroll while open. On `lg+` the
// sidebar is static and the toggle button is hidden, so this is inert there.
// Replaces the inline <script> those layouts used to carry.
export default class extends Controller {
  static targets = ['sidebar', 'backdrop', 'button']

  toggle () {
    this.setOpen(this.sidebarTarget.classList.contains('-translate-x-full'))
  }

  close () {
    this.setOpen(false)
  }

  setOpen (open) {
    this.sidebarTarget.classList.toggle('-translate-x-full', !open)
    this.backdropTarget.classList.toggle('hidden', !open)
    if (this.hasButtonTarget) {
      this.buttonTarget.setAttribute('aria-expanded', open ? 'true' : 'false')
    }
    document.body.classList.toggle('overflow-hidden', open)
  }
}
