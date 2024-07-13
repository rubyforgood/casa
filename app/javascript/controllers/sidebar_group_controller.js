import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['title', 'list', 'link']

  connect () {
    this.toggleShow()
    this.toggleShowAnchorList()
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

  // For group list with anchor links where method above does not work because 
  // active does not get triggered in sidebar_helper.rb
  // This will be temporary until ScrollSpy is implemented so active state toggles
  // with scrolling.
  // Goal: When link is assigned active with other JS implementation.
  //       trigger the bellow toggle to Happen.
  toggleShowAnchorList () {
    let currentPath = window.location.pathname
    if (currentPath == "/casa_org/1/edit" && this.titleTarget.innerText == "Edit Organization") {
      this.titleTarget.classList.remove('collapsed')
      this.listTarget.classList.add('show')
    }
  }
}
