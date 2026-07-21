import { Controller } from '@hotwired/stimulus'

// Contact-topic checklist for the case-contact form (details). Every org contact topic is
// listed; checking one reveals its notes field and CREATES the ContactTopicAnswer right away
// (POST /contact_topic_answers, storing the new id) so the 2s autosave then only UPDATES it --
// this is what keeps autosave from writing duplicate answers. Unchecking destroys the answer.
// Unchecked topics keep their fields `disabled` so they never submit an empty answer.
//
// Connects to data-controller="contact-topics"
export default class extends Controller {
  static values = { route: String, caseContactId: Number }
  static targets = ['dialog']

  connect () {
    this.headers = { 'Content-Type': 'application/json', Accept: 'application/json' }
    const token = document.querySelector('meta[name="csrf-token"]')
    if (token) { this.headers['X-CSRF-Token'] = token.content } // absent in the test env
  }

  toggle (e) {
    const group = e.target.closest('[data-topic-group]')
    const notes = group.querySelector('[data-topic-notes]')
    const fields = notes.querySelectorAll('input, textarea')
    const idField = notes.querySelector('input[name*="[id]"]')
    const textarea = notes.querySelector('textarea')

    if (e.target.checked) {
      fields.forEach(field => { field.disabled = false })
      notes.classList.remove('hidden')
      if (!idField.value) { this.create(group, idField) }
      textarea.focus()
    } else if (textarea.value.trim() && this.hasDialogTarget) {
      // Has notes: confirm through the design-system <dialog>, not a browser confirm(). Keep the
      // topic checked until the user confirms; confirmRemove -> removeTopic does the real removal.
      e.target.checked = true
      this.pendingGroup = group
      this.dialogTarget.showModal()
    } else {
      this.removeTopic(group)
    }
  }

  // Confirm button inside the removal dialog.
  confirmRemove () {
    if (this.pendingGroup) {
      this.removeTopic(this.pendingGroup)
      this.pendingGroup = null
    }
    this.dialogTarget.close()
  }

  removeTopic (group) {
    const notes = group.querySelector('[data-topic-notes]')
    const idField = notes.querySelector('input[name*="[id]"]')
    group.querySelector('input[type="checkbox"]').checked = false
    if (idField.value) { this.destroy(idField) }
    notes.classList.add('hidden')
    notes.querySelectorAll('input, textarea').forEach(field => { field.disabled = true })
  }

  create (group, idField) {
    const value = group.querySelector('textarea').value
    fetch(this.routeValue, {
      method: 'POST',
      headers: this.headers,
      body: JSON.stringify({
        contact_topic_answer: {
          contact_topic_id: group.dataset.topicId,
          case_contact_id: this.caseContactIdValue,
          value
        }
      })
    })
      .then(response => response.ok ? response.json() : Promise.reject(response))
      .then(data => { idField.value = data.id })
      .catch(error => console.error('Failed to create contact topic answer', error.status, error.statusText))
  }

  destroy (idField) {
    fetch(`${this.routeValue}/${idField.value}`, { method: 'DELETE', headers: this.headers })
      .then(response => { if (response.ok) { idField.value = '' } })
      .catch(error => console.error('Failed to destroy contact topic answer', error.status, error.statusText))
  }
}
