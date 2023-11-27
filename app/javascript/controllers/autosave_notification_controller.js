import Autosave from 'stimulus-rails-autosave'

export default class extends Autosave {
  static targets = ["alert"]

  save() {
    this.element.requestSubmit()
    this.alertTarget.innerHTML = "Saved!"
  }

  alert() {
    this.alertTarget.innerHTML = "Autosaving..."
  }
}
