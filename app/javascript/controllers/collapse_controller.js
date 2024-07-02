import { Controller } from '@hotwired/stimulus'
import { Collapse } from 'bootstrap'

// Connects to data-controller="collapse"
export default class extends Controller {
  static targets = ['collapsible']

  initialize () {
    const isCollapsed = window.sessionStorage.getItem('filtersCollapsed') === 'true'

    if (isCollapsed) {
      this.collapsibleTarget.classList.add('collapse')
    } else {
      this.collapsibleTarget.classList.add('collapse', 'show')
    }
  }

  connect () {
    this.collapsible = Collapse.getOrCreateInstance(this.collapsibleTarget, { toggle: false })
  }

  toggle () {
    const isCollapsed = !this.collapsibleTarget.classList.contains('show')

    this.collapsible.toggle()

    window.sessionStorage.setItem('filtersCollapsed', isCollapsed ? 'false' : 'true')
  }
}
