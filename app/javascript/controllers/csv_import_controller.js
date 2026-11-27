import { Controller } from '@hotwired/stimulus'

// Volunteer/supervisor CSV import form. Blocks a submit with no file chosen (inline error + focus),
// and keeps the chosen file in localStorage (keyed on the input id) so it can be put back after the
// SMS opt-in step reloads the page. The stored copy is removed on every page load, so it never
// outlives the opt-in round trip.
export default class extends Controller {
  static targets = ['input', 'error', 'optIn']

  connect () {
    const key = this.inputTarget.id
    const stored = window.localStorage.getItem(key)
    if (stored && this.hasOptInTarget && this.inputTarget.files.length === 0) {
      const { name, data } = JSON.parse(stored)
      const bytes = Uint8Array.from(window.atob(data.split(',')[1]), (c) => c.charCodeAt(0))
      const transfer = new window.DataTransfer()
      transfer.items.add(new window.File([bytes], name, { type: 'text/csv' }))
      this.inputTarget.files = transfer.files
    }
    window.localStorage.removeItem(key)
  }

  guard (event) {
    if (this.inputTarget.files.length === 0) {
      event.preventDefault()
      event.stopPropagation()
      if (this.hasErrorTarget) this.errorTarget.classList.remove('hidden')
      this.inputTarget.focus()
    }
  }

  store () {
    const file = this.inputTarget.files[0]
    if (!file) return
    if (this.hasErrorTarget) this.errorTarget.classList.add('hidden')

    const key = this.inputTarget.id
    const reader = new window.FileReader()
    reader.onload = () => window.localStorage.setItem(key, JSON.stringify({ name: file.name, data: reader.result }))
    reader.readAsDataURL(file)
  }
}
