import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['title', 'list', 'link']

  connect () {
    const performToggleShow = this.linkTargets.find((link) => {
      return link.classList.contains('active')
    }) || this.isAnchorGroupPage()

    if (performToggleShow) {
      this.toggleShow()
    }

    if (this.isAnchorGroupPage()) {
      this.initializeMenuHighlight()
    }
  }

  // Expands list if a link is active
  toggleShow () {
    this.titleTarget.classList.remove('collapsed')
    this.listTarget.classList.add('show')
  }

  anchorLinkMap () {
    const hash = {}
    this.linkTargets.forEach(link => {
      const href = link.firstElementChild.href
      if (href.includes('#')) {
        const headerId = href.substring(href.indexOf('#') + 1)
        hash[headerId] = link
      }
    })
    return hash
  }

  initializeMenuHighlight () {
    const linkHash = this.anchorLinkMap()

    const observer = new window.IntersectionObserver(entries => {
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

    document.querySelectorAll('h1[id], h2[id]').forEach((header) => {
      observer.observe(header)
    })
  }

  isAnchorGroupPage () {
    const href = this.linkTarget.firstElementChild.href
    const hrefAnchorString = href.substring(href.indexOf('#') + 1)
    if (document.getElementById(hrefAnchorString)) {
      return true
    }
  }
}
