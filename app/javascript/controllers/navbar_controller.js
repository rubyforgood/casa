import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static outlets = ['sidebar']

  click () {
    // This simulates a click action on the sidebar-controller
    this.sidebarOutlet.click()
  }
}
