import { Controller } from '@hotwired/stimulus'
import { debounce } from 'lodash'

export default class extends Controller {
  static targets = ['form', 'alert']
  static values = {
    delay: {
      type: Number,
      default: 1000 // milliseconds to delay form submission
    }
  }

  static classes = ['goodAlert', 'badAlert']

  connect () {
    this.save = debounce(this.save, this.delayValue).bind(this)
  }

  save () {
    this.autosaveAlert()
    this.submitForm()
  }

  submitForm () {
    fetch(this.formTarget.action, {
      method: 'POST',
      headers: { Accept: 'application/json' },
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
