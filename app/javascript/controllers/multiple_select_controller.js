import { Controller } from '@hotwired/stimulus'
import TomSelect from 'tom-select'

// Open the dropdown above the control when there isn't room below, so a field
// near the bottom of the page keeps its menu on-screen. `this` is the TomSelect
// instance when these run.
function onDropdownOpen (dropdown) {
  const rect = this.control.getBoundingClientRect()
  const needed = dropdown.offsetHeight || 240
  this.wrapper.classList.toggle('ts-flip-up', window.innerHeight - rect.bottom < needed && rect.top > needed)
}
function onDropdownClose () {
  this.wrapper.classList.remove('ts-flip-up')
}

export default class extends Controller {
  static targets = ['select', 'option', 'item', 'hiddenItem', 'selectAllOption']
  static values = {
    options: Array,
    selectedItems: Array,
    withOptions: Boolean,
    submitOnClose: Boolean,
    placeholder: String,
    placeholderTerm: {
      type: String,
      default: 'contact(s)'
    },
    showAllOption: Boolean
  }

  connect () {
    // Read the native <select>'s accessible name BEFORE TomSelect init: it rewrites a <label for=...>
    // to target its own input, and ignores an aria-label set on the <select>.
    this.accessibleName = this.nativeAccessibleName()
    if (this.withOptionsValue) {
      this.createMultiSelectWithOptionGroups()
    } else {
      this.createBasicMultiSelect()
    }
    this.nameNativeSelect()
    if (this.submitOnCloseValue) this.deferSubmitUntilDropdownCloses()
  }

  // An auto-submitting filter re-renders the whole page on `change`, which tears down the open menu:
  // picking five contact types meant five page loads and five reopenings of the dropdown. Hold the
  // submit while the menu is open and fire it once on close, so a selection session costs one render.
  // A change with the menu already shut (the clear-all x) still submits immediately.
  deferSubmitUntilDropdownCloses () {
    const select = this.tomSelect
    let pending = false

    select.on('change', () => {
      if (select.isOpen) {
        pending = true
      } else {
        this.submitForm()
      }
    })

    select.on('dropdown_close', () => {
      if (!pending) return
      pending = false
      this.submitForm()
    })
  }

  submitForm () {
    const form = this.element.closest('form')
    if (form) form.requestSubmit()
  }

  // Distinct non-blank groups, in the order the options arrive (the Select/Unselect all pseudo-option
  // carries a blank group and stays ungrouped, above the first header).
  optgroupsFrom (options) {
    const seen = []
    options.forEach((option) => {
      if (option.group && !seen.includes(option.group)) seen.push(option.group)
    })
    return seen.map((group) => ({ value: group, label: group }))
  }

  // Re-name the native <select> AFTER init. TomSelect repoints the <label for=...> at its own control
  // input, which leaves the original <select> nameless -- and it stays in the accessibility tree
  // (.ts-hidden-accessible clips it rather than display:none), so axe's select-name rule fails
  // (critical). Stamping the pre-init name on as an aria-label gives it a name TomSelect can't take.
  nameNativeSelect () {
    if (this.accessibleName && !this.selectTarget.getAttribute('aria-label')) {
      this.selectTarget.setAttribute('aria-label', this.accessibleName)
    }
  }

  // The native <select>'s accessible name -- its aria-label, or its associated <label> text.
  nativeAccessibleName () {
    const label = this.selectTarget.labels && this.selectTarget.labels[0]
    return this.selectTarget.getAttribute('aria-label') || (label && label.textContent.trim())
  }

  // Copy that name onto TomSelect's control input, so a <select> labelled only by aria-label (the rich
  // Form::MultipleSelectComponent) doesn't render an input named only by its placeholder.
  labelControlInput (tomSelect) {
    if (this.accessibleName && tomSelect.control_input) {
      tomSelect.control_input.setAttribute('aria-label', this.accessibleName)
    }
  }

  createBasicMultiSelect () {
    const settings = {
      plugins: {
        remove_button: {
          title: 'Remove this item'
        },
        // Clear-all inside the control, matching the searchable single-select. remove_button only
        // gives a per-chip x, which is a chip-at-a-time chore once several are picked.
        clear_button: {
          title: 'Clear all selections'
        }
      },
      onDropdownOpen,
      onDropdownClose
    }
    // A blank-load filter shows a placeholder ("Select or search supervisors", ...) until an item is
    // picked; hidePlaceholder clears the prompt once a chip exists (industry standard -- a lingering
    // placeholder next to selected chips reads as unfinished).
    if (this.placeholderValue) {
      settings.placeholder = this.placeholderValue
      settings.hidePlaceholder = true
    }
    this.tomSelect = new TomSelect(this.selectTarget, settings)
    this.labelControlInput(this.tomSelect)
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
      // Load blank (placeholder) when nothing is pre-selected; the dropdown's
      // "Select/Unselect all" still selects everything on demand.
      initItems = hasInitialItems ? emptyItem.concat(this.selectedItemsValue) : []
    }

    const dropdownOptions = showAllOptionCheck
      ? [{ text: 'Select/Unselect all', subtext: '', value: ' ', group: '' }].concat(this.optionsValue)
      : this.optionsValue

    const select = new TomSelect(this.selectTarget, {
      onDropdownOpen,
      onDropdownClose,
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
        clear_button: {
          title: 'Clear all selections'
        },
        checkbox_options: {
          checkedClassNames: ['form-check-input', 'form-check-input--checked'],
          uncheckedClassNames: ['form-check-input', 'form-check-input--unchecked']
        }
      },
      options: dropdownOptions,
      // Render the groups the options already carry. Without optgroups/optgroupField TomSelect uses
      // `group` for SEARCH only and shows a flat list, so this menu threw its grouping away while the
      // filter's showed it -- the same data, two different menus.
      optgroups: this.optgroupsFrom(dropdownOptions),
      optgroupField: 'group',
      lockOptgroupOrder: true,
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
    this.tomSelect = select
    this.labelControlInput(select)
  }
}
