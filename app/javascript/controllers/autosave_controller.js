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
        const event = new CustomEvent('autosave:success', { bubbles: true }) // eslint-disable-line no-undef
        this.element.dispatchEvent(event)
      } else {
        return Promise.reject(response)
      }
    }).catch(error => {
      console.error(error.status, error.statusText)
      switch (error.status) {
        case 504:
          this.badAlert('Connection lost: Changes will be saved when connection is restored.')
          break
        case 422:
          error.json().then(errorJson => {
            console.error('errorJson', errorJson)
            const errorMessage = errorJson.join('. ')
            this.badAlert(`Unable to save: ${errorMessage}`)
          })
          break
        case 401:
          this.badAlert('You must be signed in to save changes.')
          break
        default:
          this.badAlert('Error: Unable to save changes.')
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
