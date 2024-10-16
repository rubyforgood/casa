import NestedForm from '@stimulus-components/rails-nested-form'

/**
 * Allows nested forms to be used with the autosave controller,
 * creating and destroying records so that the autosave updates do not attempt
 * to create/destroy same nested records repeatedly.
 *
 * Extends stimulus-rails-nested-form.
 * https://www.stimulus-components.com/docs/stimulus-rails-nested-form/
 * add() & remove() are standard, so can be used as stimulus-rails-nested-form.
 * No values are necessary in that case.
 *
 * Created for the the CaseContact form (details), see its usage there.
 *
 * Connects to data-controller="casa-nested-form"
 */
export default class extends NestedForm {
  static values = {
    route: String, // path to create/destroy a record, e.g. "/contact_topic_answers"
    parentName: String, // snake case name of parent model, e.g. "case_contact"
    parentId: Number, // id of record this form is nested within e.g. @case_contact.id
    modelName: String, // name of nested form, e.g. "contact_topic_answer"
    requiredFields: { // fields required (belongs_to etc...) to pass validation (e.g. contact_topic_id)
      type: Array, default: []
    }
  }

  connect () {
    super.connect()

    const headers = new Headers()
    headers.append('Content-Type', 'application/json')
    headers.append('Accept', 'application/json')
    const tokenTag = document.querySelector('meta[name="csrf-token"]')
    if (tokenTag) { // does not exist in test environment
      headers.append('X-CSRF-Token', tokenTag.content)
    }
    this.headers = headers

    document.addEventListener('autosave:success', this.onAutosaveSuccess)
  }

  disconnect () {
    document.removeEventListener('autosave:success', this.onAutosaveSuccess)
  }

  getRecordId (wrapper) {
    const recordInput = wrapper.querySelector('input[name*="id"]')
    if (!recordInput) {
      console.warn('id input not found for nested item:', wrapper)
      return ''
    }
    return recordInput.value
  }

  /* removes any items that have been marked as _destroy: true */
  /* must be marked for destroy elsewhere, see case_contact_form_controller clearExpenses() */
  onAutosaveSuccess = (_e) => {
    const wrappers = this.element.querySelectorAll(this.wrapperSelectorValue)
    wrappers.forEach(wrapper => {
      const destroyInput = wrapper.querySelector("input[name*='_destroy']")
      if (!destroyInput) {
        console.warn('Destroy input not found for nested item:', wrapper)
        return
      }
      if (destroyInput.value === '1') {
        // autosave has already destroyed the record, remove the element from DOM
        wrapper.remove()
      }
    })
  }

  /* Adds item to the form. Item will not be created until form submission. */
  add (e) {
    super.add(e)
  }

  /* Creates a new record for the added item (before submission). */
  addAndCreate (e) {
    this.add(e)
    const items = this.element.querySelectorAll(this.wrapperSelectorValue)
    const addedItem = items[items.length - 1]
    // childIndex will be 0,1,... for items at page load, timestamps for items added to form.
    const childIndex = addedItem.dataset.childIndex
    const domIdBase = `${this.parentNameValue}_${this.modelNameValue}s_attributes_${childIndex}`

    const fields = {}
    fields[`${this.parentNameValue}_id`] = this.parentIdValue

    this.requiredFieldsValue.forEach(field => {
      const fieldId = `${domIdBase}_${field}`
      const fieldEl = document.querySelector(`#${fieldId}`)
      if (!fieldEl) {
        console.warn('Aborting: Field not found:', fieldId)
        return
      }
      fields[field] = fieldEl.value
    })

    if (Object.values(fields).some(value => value === '')) {
      console.warn('Aborting: Required field empty:', fields)
      return
    }

    const body = {}
    body[this.modelNameValue] = fields

    fetch(this.routeValue, {
      method: 'POST',
      headers: this.headers,
      body: JSON.stringify(body)
    })
      .then(response => {
        if (response.ok) {
          return response.json()
        } else {
          return Promise.reject(response)
        }
      })
      .then(data => {
        const idAttr = `${domIdBase}_id`
        const idField = document.querySelector(`#${idAttr}`)
        idField.setAttribute('value', data.id)
        addedItem.dataset.newRecord = false
      })
      .catch(error => {
        console.error(error.status, error.statusText)
        error.json().then(errorJson => {
          console.error('errorJson', errorJson)
        })
      })
  }

  /* Removes item from the form. Will not destroy record until form submission. */
  remove (e) {
    super.remove(e)
  }

  /* Destroys a record when removing the item (before submission). */
  destroyAndRemove (e) {
    const wrapper = e.target.closest(this.wrapperSelectorValue)
    const recordId = this.getRecordId(wrapper)
    if (wrapper.dataset.newRecord === 'false' && (recordId.length > 0)) {
      fetch(`${this.routeValue}/${recordId}`, {
        method: 'DELETE',
        headers: this.headers
      })
        .then(response => {
          if (response.ok) {
            // destroy successful; remove as if new record
            wrapper.dataset.newRecord = true
            this.remove(e)
          } else {
            return Promise.reject(response)
          }
        })
        .catch(error => {
          console.error(error.status, error.statusText)
          if (error.status === 404) {
            // NOT FOUND: already deleted -> remove as if new record
            wrapper.dataset.newRecord = true
            this.remove(e)
          } else {
            error.json().then(errorJson => {
              console.error('errorJson', errorJson)
            })
          }
        })
    } else {
      console.warn(
        'Conflicting information while trying to destroy record:', {
          wrapperDatasetNewRecord: wrapper.dataset.newRecord,
          recordId
        }
      )
      this.remove(e) // treat as typical removal
    }
  }

  confirmDestroyAndRemove (e) {
    const text = 'Are you sure you want to remove this item?'
    if (window.confirm(text)) {
      this.destroyAndRemove(e)
    }
  }
}
