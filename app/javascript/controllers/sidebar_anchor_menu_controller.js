/* global IntersectionObserver */

import { Controller } from '@hotwired/stimulus'
// Connects to data-controller="sidebar-anchor-menu"
export default class extends Controller {
  static targets = ['title', 'list', 'link']

  connect () {
    if (this.isEditOrganization()) {
      this.toggleShowAnchorList()
      this.menuHighlight()
    }
  }

  // For group list with anchor links where toggleShow() does not work because
  // active class does not get triggered in sidebar_helper.rb
  toggleShowAnchorList () {
    this.titleTarget.classList.remove('collapsed')
    this.listTarget.classList.add('show')
  }

  // Highlights menu items as user scrolls on page. Implemented for casa_org/1/edit#organization-details.
  menuHighlight () {
    /**
     * Constructs a map where the keys are header Ids extracted from the href attributes of the links,
     * and the values are the corresponding link elements.
     *
     * @returns {Object} A hash map with header Ids as keys and link elements as values.
     */
    const linkTargetsMap = () => {
      const hash = {}
      this.linkTargets.forEach(link => {
        const href = link.children[0].href
        const headerId = href.substring(href.indexOf('#') + 1)
        hash[headerId] = link
      })
      return hash
    }

    // Call linkTargetsMap() and assign it to linkHash
    const linkHash = linkTargetsMap()

    // add class active to link if it on page
    const observer = new IntersectionObserver(entries => {
      entries.forEach(entry => {
        if (entry.intersectionRatio > 0) {
          this.linkTargets.forEach(link => link.classList.remove('active'))

          const headerId = entry.target.id
          const activeLink = linkHash[headerId]
          if (activeLink) {
            activeLink.classList.add('active')
          }
        }
      })
    })

    // Observe edit org page header, if they match linkTargetMap, observer gets triggered
    document.querySelectorAll('h1[id], h2[id]').forEach((header) => {
      observer.observe(header)
    })
  }

  /**
   * Checks to see if user is in /casa_org/1/edit path.
   *
   * @returns {Boolean}
   */
  isEditOrganization () {
    const currentPath = window.location.pathname
    return (currentPath === '/casa_org/1/edit' && this.titleTarget.innerText === 'Edit Organization')
  }
}
