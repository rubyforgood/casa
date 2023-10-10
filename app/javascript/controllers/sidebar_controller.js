import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['sidebar', 'menu', 'logo', 'linkTitle', 'groupList']
  static values = {
    open: Boolean,
    breakpoint: { type: Number, default: 770 }
  }

  static outlets = ['sidebar-group']

  click () {
    this.openValue = !this.openValue
    this.toggleSidebar()
    if (this.isNotMobile()) {
      this.toggleLinks()
      const mainWrapper = document.querySelector('.main-wrapper')
      mainWrapper.classList.toggle('active')
    } else {
      this.toggleOverlay()
    }
  }

  hoverOn () {
    this.toggleHover()
  }

  hoverOff () {
    this.toggleHover()
  }

  toggleHover () {
    if (!this.openValue && this.isNotMobile()) {
      this.toggleSidebar()
      this.toggleLinks()
    }
  }

  toggleSidebar () {
    this.sidebarTarget.classList.toggle('active')
  }

  toggleLinks () {
    this.linkTitleTargets.forEach((target) => {
      target.classList.toggle('d-none')
    })
    this.groupListTargets.forEach((list) => {
      list.classList.toggle('nav-item-has-children')
    })
    this.logoTarget.classList.toggle('d-none')
  }

  toggleOverlay () {
    const overlay = document.querySelector('.overlay')
    overlay.classList.toggle('active')
  }

  isNotMobile () {
    return window.screen.width >= this.breakpointValue
  }
}
