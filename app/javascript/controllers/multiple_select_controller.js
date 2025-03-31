import { Controller } from '@hotwired/stimulus'
import TomSelect from 'tom-select'

export default class extends Controller {
  static targets = ['select', 'option', 'item', 'hiddenItem', 'selectAllOption']
  static values = {
    options: Array,
    selectedItems: Array,
    withOptions: Boolean,
    placeholderTerm: {
      type: String,
      default: 'contact(s)'
    },
    showAllOption: Boolean
  }

  connect () {
    if (this.withOptionsValue) {
      this.createMultiSelectWithOptionGroups()
    } else {
      this.createBasicMultiSelect()
    }
  }

  createBasicMultiSelect () {
    /* eslint-disable no-new */
    new TomSelect(this.selectTarget, {
      plugins: {
        remove_button: {
          title: 'Remove this item'
        }
      }
    })
  }

  createMultiSelectWithOptionGroups () {
    const optionTemplate = this.optionTarget.innerHTML
    const itemTemplate = this.itemTarget.innerHTML
    const placeholder = `Select or search ${this.placeholderTermValue}`

    const showAllOptionCheck = this.showAllOptionValue
    const hiddenItemTemplate = showAllOptionCheck && this.hiddenItemTarget && this.hiddenItemTarget.innerHTML
    const showAllOptionTemplate = showAllOptionCheck && this.selectAllOptionTarget && this.selectAllOptionTarget.innerHTML

    // orderedOptionVals is of type (" " | number)[] - the " " could appear
    // because using it as the value for the select/unselect all option
    let orderedOptionVals = this.optionsValue.map(opt => opt.value)
    if (showAllOptionCheck) {
      // using " " as value instead of "" bc tom-select doesn't init the "" in the item list
      orderedOptionVals = [' '].concat(orderedOptionVals)
    }

    const hasInitialItems = Array.isArray(this.selectedItemsValue) && this.selectedItemsValue.length
    // initItems: number[], possibly empty
    let initItems = this.selectedItemsValue
    if (showAllOptionCheck) {
      const emptyItem = [' ']
      initItems = hasInitialItems ? emptyItem.concat(this.selectedItemsValue) : orderedOptionVals
    }

    const dropdownOptions = showAllOptionCheck
      ? [{ text: 'Select/Unselect all', subtext: '', value: ' ', group: '' }].concat(this.optionsValue)
      : this.optionsValue

    /* eslint-disable no-new */
    new TomSelect(this.selectTarget, {
      onItemRemove: function (value) {
        if (value === ' ') {
          this.clear()
        }
      },
      onItemAdd: function (value) {
        this.setTextboxValue('')
        this.refreshOptions()

        if (value === ' ') {
          this.addItems(orderedOptionVals)
        }
      },
      plugins: {
        remove_button: {
          title: 'Remove this item',
          className: 'btn text-white rounded-circle',
          label: '<i class="lni lni-cross-circle"></i>'
        },
        checkbox_options: {
          checkedClassNames: ['form-check-input', 'form-check-input--checked'],
          uncheckedClassNames: ['form-check-input', 'form-check-input--unchecked']
        }
      },
      options: dropdownOptions,
      items: initItems,
      placeholder,
      hidePlaceholder: true,
      searchField: ['text', 'group'],
      render: {
        option: function (data, escape) {
          let html

          if (showAllOptionCheck && data && data.value === ' ') {
            html = showAllOptionTemplate.replace(/DATA_LABEL/g, escape(data.text))
          } else {
            html = optionTemplate.replace(/DATA_LABEL/g, escape(data.text))
            html = html.replace(/DATA_SUB_TEXT/g, escape(data.subtext))
          }
          return html
        },
        item: function (data, escape) {
          return showAllOptionCheck && data.value === ' ' ? hiddenItemTemplate : itemTemplate.replace(/DATA_LABEL/g, escape(data.text))
        }
      }
    })
  }
}
