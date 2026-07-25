import { Controller } from '@hotwired/stimulus'

// Settings master-detail. Two independent presentations of the same sections:
//   * Desktop (lg+): a left rail selects ONE panel -- exactly one section is shown
//     (non-selected sections are `lg:hidden`).
//   * Mobile (<lg): an accordion -- each section is a card whose body toggles open/closed
//     (`max-lg:hidden`), zero or one open at a time; tapping an open header collapses it.
// The two live on separate classes (`lg:hidden` on the <section> vs `max-lg:hidden` on the body)
// so a mobile collapse never blanks the desktop panel and vice-versa. Progressive enhancement:
// with JS off nothing is hidden and every section is a plain scroll.
export default class extends Controller {
  static targets = ['link', 'section']

  connect () {
    this.onHash = this.onHash.bind(this)
    const hashKey = this.keyFromHash()
    const first = this.sectionTargets[0]
    this.selectPanel(hashKey || (first && first.dataset.key)) // desktop: one panel always open
    this.openKey = hashKey || null // mobile: collapsed unless deep-linked
    this.applyAccordion()
    window.addEventListener('hashchange', this.onHash)
  }

  disconnect () {
    window.removeEventListener('hashchange', this.onHash)
  }

  onHash () {
    const key = this.keyFromHash()
    if (!key) return
    this.selectPanel(key)
    this.openKey = key
    this.applyAccordion()
  }

  // Desktop rail link.
  navigate (event) {
    event.preventDefault()
    const key = event.currentTarget.dataset.key
    this.selectPanel(key)
    this.setHash(key)
  }

  // Mobile accordion header: open a closed section, or collapse the one that's open.
  toggle (event) {
    const key = event.currentTarget.dataset.key
    this.openKey = (this.openKey === key) ? null : key
    this.applyAccordion()
    if (this.openKey) this.setHash(this.openKey)
  }

  selectPanel (key) {
    if (!key) return
    this.sectionTargets.forEach((section) => {
      section.classList.toggle('lg:hidden', section.dataset.key !== key)
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
  }

  applyAccordion () {
    this.sectionTargets.forEach((section) => {
      const open = section.dataset.key === this.openKey
      const body = section.querySelector('[data-settings-nav-body]')
      if (body) body.classList.toggle('max-lg:hidden', !open)
      const chevron = section.querySelector('[data-settings-nav-chevron]')
      if (chevron) chevron.classList.toggle('rotate-180', open)
      const acc = section.querySelector('[data-settings-nav-acc]')
      if (acc) acc.setAttribute('aria-expanded', open ? 'true' : 'false')
    })
  }

  setHash (key) {
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
