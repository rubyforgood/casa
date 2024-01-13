import { Controller } from '@hotwired/stimulus'

// Connects to data-controller="select-all"
export default class extends Controller {
  static targets = ['checkboxAll', 'checkbox', 'button', 'buttonLabel']
  static values = {
    allChecked: { type: Boolean, default: false },
    buttonLabel: { type: String }
  }

  static classes = ['hidden']

  toggleAll () {
    this.allCheckedValue = !this.allCheckedValue

    this.checkboxTargets.forEach(checkbox => {
      checkbox.checked = this.allCheckedValue
    })

    this.toggleButton()
  }

  toggleSingle () {
    this.toggleCheckedAll()
    this.toggleButton()
  }

  toggleCheckedAll () {
    const numChecked = this.getNumberChecked()
    const numTotal = this.getTotalCheckboxes()

    this.allCheckedValue = numChecked === numTotal
    this.checkboxAllTarget.checked = this.allCheckedValue

    if (numChecked === 0) {
      this.checkboxAllTarget.indeterminate = false
    } else {
      this.checkboxAllTarget.indeterminate = numChecked < numTotal
    }
  }

  toggleButton () {
    if (this.hasButtonTarget) {
      const numChecked = this.getNumberChecked()
      if (numChecked > 0) {
        if (this.hasButtonLabelTarget) {
          let label = this.buttonLabelValue
          if (numChecked > 1) {
            label += 's'
          }
          label += ' (' + numChecked + ')'
          this.buttonLabelTarget.innerHTML = label
        }

        this.buttonTarget.classList.remove(this.hiddenClass)
      } else {
        this.buttonTarget.classList.add(this.hiddenClass)
      }
    }
  }

  getNumberChecked () {
    return this.checkboxTargets.filter((checkbox) => checkbox.checked).length
  }

  getTotalCheckboxes () {
    return this.checkboxTargets.length
  }
}
