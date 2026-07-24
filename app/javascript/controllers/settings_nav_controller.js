import { Controller } from '@hotwired/stimulus'

// Settings master-detail: the grouped sub-nav selects one section at a time.
// Progressive enhancement -- with JS off every section stays visible (a plain scroll).
// On connect we collapse to a single panel (desktop rail selection / mobile accordion),
// defaulting to the first section or the one named in the URL hash so deep links
// (e.g. the case-contact form -> #case-contact-topics) open the right section.
export default class extends Controller {
  static targets = ['link', 'section']

  connect () {
    this.onHash = this.onHash.bind(this)
    const first = this.sectionTargets[0]
    this.select(this.keyFromHash() || (first && first.dataset.key))
    window.addEventListener('hashchange', this.onHash)
  }

  disconnect () {
    window.removeEventListener('hashchange', this.onHash)
  }

  onHash () {
    const key = this.keyFromHash()
    if (key) this.select(key)
  }

  navigate (event) {
    event.preventDefault()
    this.select(event.currentTarget.dataset.key)
  }

  toggle (event) {
    this.select(event.currentTarget.dataset.key)
  }

  select (key) {
    if (!key) return
    this.sectionTargets.forEach((section) => {
      const active = section.dataset.key === key
      section.classList.toggle('lg:hidden', !active)
      const body = section.querySelector('[data-settings-nav-body]')
      if (body) body.classList.toggle('hidden', !active)
      const chevron = section.querySelector('[data-settings-nav-chevron]')
      if (chevron) chevron.classList.toggle('rotate-180', active)
      const acc = section.querySelector('[data-settings-nav-acc]')
      if (acc) acc.setAttribute('aria-expanded', active ? 'true' : 'false')
    })
    this.linkTargets.forEach((link) => {
      const active = link.dataset.key === key
      link.classList.toggle('bg-brand-50', active)
      link.classList.toggle('font-semibold', active)
      link.classList.toggle('text-brand-700', active)
      link.classList.toggle('text-slate-600', !active)
      if (active) link.setAttribute('aria-current', 'page')
      else link.removeAttribute('aria-current')
    })
    try {
      window.history.replaceState(null, '', '#' + key)
    } catch (error) {
      // history update is best-effort
    }
  }

  keyFromHash () {
    const hash = (window.location.hash || '').replace('#', '')
    return this.sectionTargets.some((section) => section.dataset.key === hash) ? hash : null
  }
}
