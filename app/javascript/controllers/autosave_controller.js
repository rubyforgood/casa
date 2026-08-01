import { Controller } from '@hotwired/stimulus'
import { debounce } from 'lodash'
import { ensureCaseContact, isPersisted, pendingCaseContact } from '../src/case_contact_draft'

export default class extends Controller {
  static targets = ['form', 'alert']
  static values = {
    delay: {
      type: Number,
      default: 1000 // milliseconds to delay form submission
    },
    clearDelay: {
      type: Number,
      default: 3000 // milliseconds to delay hiding alert
    }
  }

  static classes = ['goodAlert', 'badAlert']

  connect () {
    // display (not visibility) so a hidden status line reserves no space at the card's bottom
    this.visibleClass = 'block'
    this.hiddenClass = 'hidden'
    this.save = debounce(this.save, this.delayValue).bind(this)
  }

  save () {
    this.autosaveAlert()
    this.submitForm()
  }

  submitForm () {
    // First save of a brand-new contact: the record does not exist yet, so create it and adopt the
    // id. Every save after that PATCHes the wizard step -- posting to create twice would insert a
    // second draft.
    if (!isPersisted(this.formTarget)) {
      ensureCaseContact(this.formTarget)
        .then(() => this.handleSuccess())
        .catch(error => this.handleError(error))
      return
    }

    fetch(this.formTarget.action, {
      method: 'POST',
      headers: { Accept: 'application/json' },
      body: new FormData(this.formTarget)
    }).then(response => {
      if (response.ok) {
        this.handleSuccess()
      } else {
        return Promise.reject(response)
      }
    }).catch(error => this.handleError(error))
  }

  // Submit is the one save that does NOT come through `ensureCaseContact`: it is a native form post,
  // so with a creation still in flight it becomes the second creation path the draft module exists to
  // prevent. The user gets two contacts -- the one they submitted, and the draft the open request
  // inserts a moment later -- which is what the roster then shows. It needs latency to happen at all
  // (checking a topic starts a create; submitting before it answers), so it hid on a fast local
  // machine and reproduced 3 of 3 in the docker container, where the browser and the app are separate
  // hosts. Hold the submit until the create resolves: `adopt` has pointed the form at the record by
  // then, so the resubmit PATCHes it instead. Keep the submitter, or the button's name/value is lost.
  holdForDraft (event) {
    const pending = pendingCaseContact()
    if (!pending || isPersisted(this.formTarget)) { return }

    event.preventDefault()
    const submitter = event.submitter
    const resubmit = () => this.formTarget.requestSubmit(submitter)
    pending.then(resubmit, resubmit)
  }

  // Both save paths land here: the nested-form controller listens for autosave:success, so the
  // create path has to announce it too or the expense rows stop reacting to saves.
  handleSuccess () {
    this.goodAlert()
    const event = new CustomEvent('autosave:success', { bubbles: true }) // eslint-disable-line no-undef
    this.element.dispatchEvent(event)
  }

  handleError (error) {
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
  }

  autosaveAlert () {
    this.removeBadAlert()
    this.alertTargets.forEach(alertTarget => {
      alertTarget.innerHTML = 'Autosaving...'
    })
    this.revealAlert()
  }

  goodAlert () {
    this.removeBadAlert()
    this.alertTargets.forEach(alertTarget => {
      alertTarget.innerHTML = 'Saved!'
    })
  }

  removeBadAlert () {
    this.alertTargets.forEach(alertTarget => {
      alertTarget.classList.add(this.goodAlertClass)
      alertTarget.classList.remove(this.badAlertClass)
    })
  }

  badAlert (message) {
    this.alertTargets.forEach(alertTarget => {
      alertTarget.classList.remove(this.goodAlertClass)
      alertTarget.classList.add(this.badAlertClass)
      alertTarget.innerHTML = message
    })
  }

  hideAlert () {
    this.alertTargets.forEach(alertTarget => {
      alertTarget.classList.add(this.hiddenClass)
      alertTarget.classList.remove(this.visibleClass)
    })
  }

  revealAlert (hide = true) {
    this.alertTargets.forEach(alertTarget => {
      alertTarget.classList.remove(this.hiddenClass)
      alertTarget.classList.add(this.visibleClass)
    })
    if (hide) {
      setTimeout(() => {
        this.hideAlert()
      }, this.clearDelayValue)
    }
  }
}
