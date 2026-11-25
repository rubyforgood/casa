import { Controller } from '@hotwired/stimulus'

// Emancipation checklist (casa_app). Replaces the jQuery src/case_emancipation.js.
//
// The page lists categories. Each category has a checkbox and a collapsible option list.
// Every toggle saves right away: the controller POSTs to emancipations#save and updates the
// DOM only after the server confirms. The server refuses some changes. A case may lack
// transition age, and an option may already be on the case.
//
// A checkbox that flipped itself early would show a state the server does not have. So the
// inputs are pointer-events-none (the click lands on the wrapper around them), and this
// controller sets `checked` itself once the save succeeds.
//
// The status line replaces the jQuery Notifier that rendered into #notifications.
// Confirmations use role="status". Errors use role="alert" and stay on screen until the
// next save.
export default class extends Controller {
  static targets = ['status', 'error']
  static values = { savePath: String }

  connect () {
    this.headers = {
      'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8',
      Accept: 'application/json'
    }
    const token = document.querySelector('meta[name="csrf-token"]')
    if (token) { this.headers['X-CSRF-Token'] = token.content } // absent in the test env
  }

  // Clicking a category's label toggles the category. Adding the category opens its options.
  // Removing the category closes them and clears the options checked underneath. The server
  // drops those options along with the category.
  async toggleCategory (event) {
    event.preventDefault()

    const labelPair = event.currentTarget
    if (this.isBusy(labelPair)) { return }

    const category = labelPair.closest('.emancipation-category')
    const checkbox = category.querySelector('.emancipation-category-check-box')
    const wasChecked = checkbox.checked

    this.busy(labelPair)
    const saved = await this.save(wasChecked ? 'delete_category' : 'add_category', checkbox.value)
    this.unbusy(labelPair)
    if (!saved) { return }

    checkbox.checked = !wasChecked

    if (wasChecked) {
      this.close(category)
      const cleared = this.clearCheckedOptions(category)
      this.setStatus(cleared.length ? `Unchecked ${cleared.join(', ')}` : 'Saved')
    } else {
      this.open(category)
      this.setStatus('Saved')
    }
  }

  // Clicking an option's row toggles that option. A radio that is already selected has nothing
  // to change, and the browser unchecks the rest of the group for us when we set it.
  async toggleOption (event) {
    event.preventDefault()

    const item = event.currentTarget
    if (this.isBusy(item)) { return }

    const input = item.querySelector('input')
    if (!input) { return }

    if (input.type === 'radio') {
      if (input.checked) { return }

      // Setting one radio replaces the whole group on the server. Block every sibling while
      // the save is in flight. The jQuery version disabled the group too.
      const group = item.parentElement.querySelectorAll('.check-item')
      group.forEach((member) => this.busy(member))
      const saved = await this.save('set_option', input.value)
      group.forEach((member) => this.unbusy(member))
      if (!saved) { return }

      input.checked = true
      this.setStatus('Saved')
      return
    }

    const wasChecked = input.checked

    this.busy(item)
    const saved = await this.save(wasChecked ? 'delete_option' : 'add_option', input.value)
    this.unbusy(item)
    if (!saved) { return }

    input.checked = !wasChecked
    this.setStatus('Saved')
  }

  // The collapse icon opens/closes a category's options. It sits beside the category's label,
  // so the click must not also toggle the category.
  toggleChildren (event) {
    event.preventDefault()

    const category = event.currentTarget.closest('.emancipation-category')
    this.setExpanded(category, !this.isOpen(category))
  }

  // ----- the save -----

  // Posts one check-state change. Returns true when the server accepted it.
  async save (action, checkItemId) {
    const body = new URLSearchParams({
      check_item_action: action,
      check_item_id: checkItemId
    })

    let response
    try {
      response = await fetch(this.savePathValue, {
        method: 'POST',
        headers: this.headers,
        body: body.toString()
      })
    } catch (error) {
      this.setError('Unable to save the change. Check your connection and try again.')
      return false
    }

    // The endpoint answers 200 with the string "success", or a non-2xx with { error: "..." }.
    const payload = await response.json().catch(() => null)

    if (!response.ok) {
      this.setError((payload && payload.error) || 'Unable to save the change.')
      return false
    }

    if (payload !== 'success') {
      this.setError((payload && payload.error) || 'Unable to save the change.')
      return false
    }

    return true
  }

  // ----- expand/collapse -----

  isOpen (category) {
    return category.dataset.isOpen === 'true'
  }

  open (category) {
    this.setExpanded(category, true)
  }

  close (category) {
    this.setExpanded(category, false)
  }

  setExpanded (category, expanded) {
    category.dataset.isOpen = expanded ? 'true' : 'false'

    const options = this.optionsFor(category)
    if (options) { options.style.display = expanded ? '' : 'none' }

    // The glyph must match EmancipationsHelper#emancipation_category_collapse_icon, which
    // renders the same two characters for the server-rendered state.
    const icon = category.querySelector('.category-collapse-icon')
    if (icon) { icon.textContent = expanded ? '−' : '+' }
  }

  // The options list is the element right after the category header (the view renders them as
  // siblings inside the checklist card).
  optionsFor (category) {
    const sibling = category.nextElementSibling
    return sibling && sibling.classList.contains('category-options') ? sibling : null
  }

  // Removing a category removes its options from the case too. Clear the checkboxes here.
  // Otherwise the page claims options that are no longer there.
  clearCheckedOptions (category) {
    const options = this.optionsFor(category)
    if (!options) { return [] }

    const cleared = []
    options.querySelectorAll('.check-item input:checked').forEach((input) => {
      input.checked = false
      const label = input.closest('.check-item').querySelector('label')
      if (label) { cleared.push(label.textContent.trim()) }
    })
    return cleared
  }

  // ----- status -----

  setStatus (message) {
    if (!this.hasStatusTarget) { return }
    this.statusTarget.textContent = message
    if (this.hasErrorTarget) { this.errorTarget.textContent = '' }
  }

  setError (message) {
    if (!this.hasErrorTarget) { return }
    this.errorTarget.textContent = message
    if (this.hasStatusTarget) { this.statusTarget.textContent = '' }
  }

  // ----- in-flight guard -----

  // A second click while a save is in flight would post the same change twice. The second
  // post can fail. An option that is already on the case counts as a duplicate.
  busy (element) {
    element.dataset.emancipationChecklistBusy = 'true'
  }

  unbusy (element) {
    delete element.dataset.emancipationChecklistBusy
  }

  isBusy (element) {
    return element.dataset.emancipationChecklistBusy === 'true'
  }
}
