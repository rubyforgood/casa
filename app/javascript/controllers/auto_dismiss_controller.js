import { Controller } from '@hotwired/stimulus'

// Auto-hides a transient status message. Applied to success flashes only (shared/_flashes):
// warnings and errors are left on screen, since they are often the only record of what went wrong
// and dismissing them for the user loses that.
//
// The timer pauses while the pointer is over the message or keyboard focus is inside it, so it
// cannot disappear mid-read -- that plus a delay well above a few seconds is what keeps an
// auto-hiding status message clear of WCAG 2.2.1. The message keeps its role="status", so screen
// readers announce it when it appears; removing it later is silent.
const FADE_MS = 300

export default class extends Controller {
  static values = { delay: { type: Number, default: 6000 } }

  connect () {
    this.start()
  }

  disconnect () {
    this.cancel()
  }

  start () {
    this.timeout = setTimeout(() => this.hide(), this.delayValue)
  }

  cancel () {
    if (this.timeout) {
      clearTimeout(this.timeout)
      this.timeout = null
    }
  }

  // data-action hooks: hold the message while the user is reading or tabbing through it.
  pause () {
    this.cancel()
  }

  resume () {
    this.cancel()
    this.start()
  }

  hide () {
    if (window.matchMedia('(prefers-reduced-motion: reduce)').matches) {
      this.element.remove()
      return
    }

    // Inline styles rather than a utility class: a class added from JS only works while Tailwind
    // still emits it, and if it were ever dropped from the build the element would silently never
    // fade *or* be removed. The removal is on a timer for the same reason -- transitionend can be
    // missed, and the message must go either way.
    this.element.style.transition = `opacity ${FADE_MS}ms`
    this.element.style.opacity = '0'
    setTimeout(() => this.element.remove(), FADE_MS + 50)
  }
}
