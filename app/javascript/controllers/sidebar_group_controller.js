/* global IntersectionObserver */

import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['title', 'list', 'link']

  connect () {
    this.toggleShow()
    if (this.isEditOrganization()) {
      this.toggleShowAnchorList()
      this.obsFunc()
    }
  }

  // Expands list if a link is active
  toggleShow () {
    this.linkTargets.forEach((link) => {
      if (link.classList.contains('active')) {
        this.titleTarget.classList.remove('collapsed')
        this.listTarget.classList.add('show')
      }
    })
  }

  // For group list with anchor links where toggleShow() does not work because
  // active class does not get triggered in sidebar_helper.rb
  toggleShowAnchorList () {
    this.titleTarget.classList.remove('collapsed')
    this.listTarget.classList.add('show')
  }

  obsFunc () {
    const observer = new IntersectionObserver(entries => {
      entries.forEach(entry => {
        if (entry.intersectionRatio > 0) {
          const headerID = entry.target.id

          this.linkTargets.forEach(link => link.classList.remove('active'))

          const activeLink = this.linkTargetsMap[headerID]
          if (activeLink) {
            activeLink.classList.add('active')
          }
        }
      })
    })

    this.linkTargetsMap = {}
    this.linkTargets.forEach(link => {
      const href = link.children[0].href
      const headerID = href.substring(href.indexOf('#') + 1)
      this.linkTargetsMap[headerID] = link
    })

    document.querySelectorAll('h1[id], h2[id]').forEach((header) => {
      observer.observe(header)
    })
  }

  isEditOrganization () {
    const currentPath = window.location.pathname
    return (currentPath === '/casa_org/1/edit' && this.titleTarget.innerText === 'Edit Organization')
  }
}
