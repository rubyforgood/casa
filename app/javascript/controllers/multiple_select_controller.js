import { Controller } from '@hotwired/stimulus'
import TomSelect from 'tom-select'

export default class extends Controller {
  static targets = ['select']
  static values = {
    options: Array,
    optionGroups: Array,
    optgroupField: String,
    labelField: String,
    defaultSelected: Array
   }

  connect () {
    const isGrouped = this.hasOptionsValue &&
                        this.hasOptionGroupsValue &&
                        this.hasOptgroupFieldValue &&
                        this.hasLabelFieldValue
    if (isGrouped) {
      /* eslint-disable no-new */
      return new TomSelect(this.selectTarget, {
        plugins: {
          remove_button: {
            title: 'Remove this item',
            className: 'text-primary p-1 mx-2 deactive-bg rounded-circle',
            label: `<i class="lni lni-close p-1"></i>`
          }
        },
        options: this.optionsValue,
        optgroups: this.optionGroupsValue,
        optgroupField: this.optgroupFieldValue,
        labelField: this.labelFieldValue,
        items: this.defaultSelectedValue,
        searchField: [this.labelFieldValue, this.optgroupFieldValue],
        render: {
          option: function(data, escape) {
            return `
                <div class='d-flex gap-1'>
                  <span class='d-flex gap-1'>${escape(data.label)}</span>
                  <span class="fst-italic text-muted">${escape(data.inline_option)}</span>
                </div>
              `.replace(/(\r\n|\n|\r)/gm,"");
          },
          optgroup_header: function(data, escape) {
            return `
              <span class='d-flex optgroup-header'>
                ${escape(data.label)}
              </span>
            `.replace(/(\r\n|\n|\r)/gm,"");
          },
          item: function(data, escape) {
            return `
              <div class="badge rounded-pill primary-bg py-2 px-3 active form-check-label">
                ${escape(data.label)}
              </div>
            `.replace(/(\r\n|\n|\r)/gm,"");
          }
        }
      })
    }
    /* eslint-disable no-new */
    new TomSelect(this.selectTarget, {
      plugins: {
        remove_button: {
          title: 'Remove this item'
        }
      }
    })
  }
}
