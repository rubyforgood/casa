import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['form', 'alert']
  static values = {
    delay: {
      type: Number,
      default: 1000 // milliseconds to delay form submission
    }
  }

  static classes = ['goodAlert', 'badAlert']

  save () {
    this.autosaveAlert()
    clearTimeout(this.timeout)
    this.timeout = setTimeout(() => this.submitForm(), this.delayValue)
  }

  submitForm () {
    fetch(this.formTarget.action, {
      method: 'POST',
      body: new FormData(this.formTarget)
    }).then(response => {
      if (response.ok) {
        this.goodAlert()
      } else {
        if (response.status === 504) {
          this.badAlert('Connection lost: Changes will be saved when connection is restored.')
        } else {
          this.badAlert('Error: Unable to save changes.')
        }
      }
    })
  }

  autosaveAlert () {
    this.removeBadAlert()
    this.alertTarget.innerHTML = 'Autosaving...'
  }

  goodAlert () {
    this.removeBadAlert()
    this.alertTarget.innerHTML = 'Saved!'
  }

  removeBadAlert () {
    this.alertTarget.classList.add(this.goodAlertClass)
    this.alertTarget.classList.remove(this.badAlertClass)
  }

  badAlert (message) {
    this.alertTarget.classList.remove(this.goodAlertClass)
    this.alertTarget.classList.add(this.badAlertClass)
    this.alertTarget.innerHTML = message
  }
}
