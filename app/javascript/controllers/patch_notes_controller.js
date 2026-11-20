import { Controller } from '@hotwired/stimulus'

// All-CASA-admin patch notes page: inline create / edit / cancel-edit / save / delete over
// fetch, with no full page reload. Replaces the ~500-line jQuery clone-CRUD that used to live
// in src/all_casa_admin/patch_notes.js. Every button is rendered by the server in
// _patch_note.html.erb with the design-system helpers (button_classes / ghost_class) -- this
// controller only toggles `hidden` / `disabled` and moves data, it never hard-codes class
// strings. A newly created note is inserted from the `html` fragment the server returns, so
// it gets the exact same markup as a page load would.
export default class extends Controller {
  static targets = ['list', 'newNoteItem', 'newNote', 'newType', 'newGroup', 'createButton']
  static values = { path: String }

  // ----- create -----

  async create (event) {
    event.preventDefault()

    const note = this.newNoteTarget.value
    if (!note) {
      this.notify('Cannot save an empty patch note', 'warn')
      return
    }

    this.setNewFormDisabled(true)
    try {
      const body = await this.request(this.pathValue, {
        method: 'POST',
        body: JSON.stringify({
          note,
          patch_note_group_id: this.newGroupTarget.value,
          patch_note_type_id: this.newTypeTarget.value
        })
      })
      this.newNoteTarget.value = ''
      this.insertNewNote(body.html)
    } catch {
      // request() already surfaced the error as a notification
    } finally {
      this.setNewFormDisabled(false)
    }
  }

  insertNewNote (html) {
    const template = document.createElement('template')
    template.innerHTML = html.trim()
    const newItem = template.content.firstElementChild
    newItem.classList.add('new') // marks the just-created note
    this.newNoteItemTarget.after(newItem)
  }

  // ----- edit / cancel / save / delete -----

  edit (event) {
    const cardBody = this.cardBodyFor(event)
    // Stash the persisted values so cancel-edit can restore them.
    cardBody.dataset.beforeEdit = JSON.stringify({
      note: this.noteField(cardBody).value,
      groupId: this.groupField(cardBody).value,
      typeId: this.typeField(cardBody).value
    })
    this.setEditMode(cardBody, true)
  }

  cancel (event) {
    const cardBody = this.cardBodyFor(event)
    const beforeEdit = JSON.parse(cardBody.dataset.beforeEdit || '{}')
    this.noteField(cardBody).value = beforeEdit.note ?? ''
    this.groupField(cardBody).value = beforeEdit.groupId ?? ''
    this.typeField(cardBody).value = beforeEdit.typeId ?? ''
    this.setEditMode(cardBody, false)
  }

  async save (event) {
    const cardBody = this.cardBodyFor(event)
    const note = this.noteField(cardBody).value
    if (note === '') {
      this.notify('Cannot save a blank patch note', 'warn')
      return
    }

    this.setItemDisabled(cardBody, true)
    try {
      await this.request(`${this.pathValue}/${cardBody.dataset.patchNoteId}`, {
        method: 'PUT',
        body: JSON.stringify({
          note,
          patch_note_group_id: this.groupField(cardBody).value,
          patch_note_type_id: this.typeField(cardBody).value
        })
      })
      this.setEditMode(cardBody, false)
    } catch {
      // Notified by request(); leave the note in edit mode so the admin can retry.
    } finally {
      this.setButtonsDisabled(cardBody, false)
    }
  }

  async delete (event) {
    const button = event.target.closest('button')
    const cardBody = this.cardBodyFor(event)
    const clicks = Number(button.dataset.deleteCount || 0)

    if (clicks === 0) {
      this.notify('Click 2 more times to delete', 'warn')
      button.dataset.deleteCount = '1'
      this.setButtonLabel(button, '2')
    } else if (clicks === 1) {
      button.dataset.deleteCount = '2'
      this.setButtonLabel(button, '1')
    } else {
      this.setItemDisabled(cardBody, true)
      try {
        await this.request(`${this.pathValue}/${cardBody.dataset.patchNoteId}`, { method: 'DELETE' })
        cardBody.closest('.patch-note-list-item').remove()
      } catch {
        this.setItemDisabled(cardBody, false)
        button.dataset.deleteCount = '0'
        this.setButtonLabel(button, 'Delete')
      }
    }
  }

  // ----- DOM helpers -----

  cardBodyFor (event) {
    return event.target.closest('[data-patch-note-id]')
  }

  noteField (cardBody) {
    return cardBody.querySelector('textarea')
  }

  typeField (cardBody) {
    return cardBody.querySelector('.note-type-select')
  }

  groupField (cardBody) {
    return cardBody.querySelector('.note-group-select')
  }

  setEditMode (cardBody, editing) {
    cardBody.querySelector('.patch-note-view-buttons').classList.toggle('hidden', editing)
    cardBody.querySelector('.patch-note-edit-buttons').classList.toggle('hidden', !editing)
    this.setInputsDisabled(cardBody, !editing)
  }

  setItemDisabled (cardBody, disabled) {
    this.setInputsDisabled(cardBody, disabled)
    this.setButtonsDisabled(cardBody, disabled)
  }

  setInputsDisabled (cardBody, disabled) {
    cardBody.querySelectorAll('textarea, select').forEach((input) => { input.disabled = disabled })
  }

  setButtonsDisabled (cardBody, disabled) {
    cardBody.querySelectorAll('button').forEach((button) => { button.disabled = disabled })
  }

  setNewFormDisabled (disabled) {
    const fields = [this.newNoteTarget, this.newTypeTarget, this.newGroupTarget, this.createButtonTarget]
    fields.forEach((field) => { field.disabled = disabled })
  }

  setButtonLabel (button, label) {
    button.querySelector('.button-label').textContent = label
  }

  // ----- fetch + notifications -----

  async request (url, options = {}) {
    const response = await this.withSavingIndicator(fetch(url, {
      headers: {
        'Content-Type': 'application/json',
        Accept: 'application/json',
        'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]')?.content
      },
      ...options
    }))

    const body = await response.json().catch(() => ({}))
    if (!response.ok || body.errors) {
      const errors = Array.isArray(body.errors) ? body.errors.join(', ') : String(body.errors || '')
      let message = `Request failed (${response.status})`
      try {
        message = JSON.parse(errors).join(', ')
      } catch {
        message = errors || message
      }
      this.notify(message, 'error')
      throw new Error(message)
    }
    return body
  }

  async withSavingIndicator (fetchPromise) {
    const waiting = this.element.querySelector('#async-waiting-indicator')
    const saved = this.element.querySelector('#async-success-indicator')
    if (waiting) waiting.style.display = ''
    try {
      const response = await fetchPromise
      if (saved) {
        saved.style.display = ''
        setTimeout(() => { saved.style.display = 'none' }, 2000)
      }
      return response
    } finally {
      if (waiting) waiting.style.display = 'none'
    }
  }

  // Minimal port of src/notifier.js's markup (no jQuery): a dismissable
  // `.{level}-notification` row inside #notifications .messages.
  notify (message, level) {
    const levelClass = { error: 'danger', info: 'success', warn: 'warning' }[level] || 'success'
    const container = this.element.querySelector('#notifications .messages')
    if (!container) return

    const notification = document.createElement('div')
    notification.className = `${levelClass}-notification`
    const span = document.createElement('span')
    span.textContent = message
    const dismiss = document.createElement('button')
    dismiss.className = `btn btn-${levelClass} btn-sm`
    dismiss.textContent = '×'
    dismiss.addEventListener('click', () => notification.remove())
    notification.append(span, dismiss)
    container.append(notification)
  }
}
