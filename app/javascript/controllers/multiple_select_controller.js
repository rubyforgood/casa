import { Controller } from '@hotwired/stimulus'
import TomSelect from 'tom-select'

export default class extends Controller {
  static targets = ['select', 'option', 'item']
  static values = {
    options: Array,
    selectedItems: Array,
    withOptions: Boolean
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

    /* eslint-disable no-new */
    new TomSelect(this.selectTarget, {
      onItemAdd: function () {
        this.setTextboxValue('')
        this.refreshOptions()
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
      options: this.optionsValue,
      items: this.selectedItemsValue,
      placeholder: 'Select or search',
      hidePlaceholder: true,
      searchField: ['text', 'group'],
      render: {
        option: function (data, escape) {
          let html = optionTemplate.replace(/DATA_LABEL/g, escape(data.text))
          html = html.replace(/DATA_SUB_TEXT/g, escape(data.subtext))
          return html
        },
        item: function (data, escape) {
          return itemTemplate.replace(/DATA_LABEL/g, escape(data.text))
        }
      }
    })
  }
}
