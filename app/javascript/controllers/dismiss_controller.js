import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['element']
  static values = {
    url: String
  }

  dismiss (event) {
    event.preventDefault()

    fetch(this.urlValue)
      .then(response => response.json())
      .then(data => {
        if (data.status === 'ok') {
          this.elementTarget.classList.add('d-none')
        }
      })
  }
}
