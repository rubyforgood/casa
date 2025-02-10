import { Controller } from '@hotwired/stimulus'
import TomSelect from 'tom-select'

export default class extends Controller {
  static targets = ['select', 'option', 'item', 'hiddenItem', 'showAllOption'] // add 'selectAllBtn' if going with button
  static values = {
    options: Array,
    selectedItems: Array,
    withOptions: Boolean,
    placeholderTerm: {
      type: String,
      default: 'contact(s)'
    },
    showAllOption: Boolean,
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
    const showAllOptionTemplate = showAllOptionCheck && this.showAllOptionTarget && this.showAllOptionTarget.innerHTML
    
    // orderedOptionVals is of type (" " | number)[] - the " " could appear
    // because using it as the value for the select/unselect all option
    let orderedOptionVals = this.optionsValue.map(opt => opt.value)
    if (showAllOptionCheck) {
      // using " " as value instead of "" bc tom-select doesn't init the "" in the item list
      orderedOptionVals = [" "].concat(orderedOptionVals)
    }

    const initItems = Array.isArray(this.selectedItemsValue) && this.selectedItemsValue.length ? showAllOptionCheck ? [" "].concat(this.selectedItemsValue) : this.selectedItemsValue : orderedOptionVals

    const dropdownOptions = showAllOptionCheck ? 
      [{ text: "Select/Unseselect all", subtext: "", value: " ", group: ""}].concat(this.optionsValue) 
        : this.optionsValue
    
    // const selectAllBtn = this.selectAllBtnTarget
    // assign TomSelect instance to this.selectEl if going with button implementation

    /* eslint-disable no-new */
    new TomSelect(this.selectTarget, {
      onItemRemove: function(value, data) {
        // for the select/unselect all button - add in short circuit in case showAllBtn doesn't exist
        // if (this.items.length < orderedOptionVals.length) {
        //   selectAllBtn.innerText = 'Select all'
        // }

        if (value === " ") {
          this.clear()
        }
      },
      onItemAdd: function (value) {
        this.setTextboxValue('')
        this.refreshOptions()

        // for the select/unselect all button - add in short circuit in case showAllBtn doesn't exist
        // if (this.items.length < orderedOptionVals.length) {
        //   selectAllBtn.innerText = 'Select all'
        // }

        if (value === " ") {
          this.addItems(orderedOptionVals);
        }
      },
      plugins: {
        remove_button: {
          title: 'Remove this item',
          className: 'btn text-white rounded-circle',
          label: '<i class="lni lni-cross-circle"></i>'
        },
        checkbox_options: {
          checkedClassNames: ['form-check-input'],
          uncheckedClassNames: ['form-check-input']
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

          if (showAllOptionCheck && data && data.value === " ") {
            html = showAllOptionTemplate.replace(/DATA_LABEL/g, escape(data.text))
          } else {
            html = optionTemplate.replace(/DATA_LABEL/g, escape(data.text))
            html = html.replace(/DATA_SUB_TEXT/g, escape(data.subtext))
          }
          return html
        },
        item: function (data, escape) {
          return showAllOptionCheck && data.value === " " ? hiddenItemTemplate : itemTemplate.replace(/DATA_LABEL/g, escape(data.text))
        }
      }
    })
  }

  // action for the select/unselect all button - add in short circuit in case showAllBtn or selectEl doesn't exist
  // toggleSelectAll() {
  //   if (!this.selectEl || !this.selectAllBtnTarget) return

  //   const checkedStatus = this.selectEl.items.length === Object.keys(this.selectEl.options).length ? "all" : "not-all"
    
  //   if (checkedStatus === "all") {
  //     this.selectEl.clear()
  //     this.selectAllBtnTarget.textContent = "Select all"
  //   } else {
  //     this.selectEl.addItems(this.optionsValue.map(opt => opt.value))
  //     this.selectAllBtnTarget.textContent = "Unselect all"
  //   }
  // }
}
