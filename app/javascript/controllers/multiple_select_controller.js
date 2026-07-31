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

// An inert stand-in for the checkbox tom-select's `checkbox_options` plugin injects into each option
// row. A real `<input>` inside `role="option"` is axe `nested-interactive` (serious) + `label`
// (critical), and axe rejects the mitigations outright: "a negative tabindex on an element inside an
// interactive control does not prevent assistive technologies from focusing the element (even with
// aria-hidden)". The row's own `aria-selected` is the state a screen reader reads, so the tick only has
// to be a shape. It keeps the plugin's classes, so every CSS and spec hook still matches.
const inertMarkerFor = (checkbox) => {
  const marker = document.createElement('span')
  marker.className = checkbox.className
  marker.setAttribute('aria-hidden', 'true')
  return marker
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
    if (!form) return

    // form.submit(), NOT requestSubmit(). The other filters on this bar submit through a jQuery
    // handler that bypasses Turbo, so they re-render the whole page. requestSubmit() fires a real
    // submit event, which Turbo intercepts and -- because the form targets a turbo-frame -- scopes to
    // the RESULTS only. The card's Clear action and filter count live outside that frame, so they
    // went stale after a multiselect change while every other filter updated them: the same bar
    // behaving two different ways. Native submit keeps all of them consistent.
    form.submit()
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
      onDropdownClose,
      // Clear the query once an item is picked, and re-score the remaining options against an empty
      // query so the next search starts clean. Without this TomSelect leaves the typed letters sitting
      // in the control beside the new chip -- reported as "the letters the user types stay even after
      // they have made a selection". The grouped path below already did this; this one did not, which
      // is why it affected every plain multiselect (contact types, case groups, all four report
      // filters) and none of the single-selects.
      onItemAdd: function () {
        this.setTextboxValue('')
        this.refreshOptions()
      }
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
        // Kept for its BEHAVIOUR, not its markup: this plugin is what makes a click on an already
        // selected row deselect it (it replaces onOptionSelect), and it owns hideSelected. Its
        // `<input type="checkbox">` is swapped for an inert span after init -- see swapCheckboxForMarker.
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
    this.swapCheckboxForMarker(select)
    select.on('item_add', () => this.syncMarkers(select))
    select.on('item_remove', () => this.syncMarkers(select))
  }

  // The plugin's own class updater looks for `input.tomselect-checkbox` and no-ops on the span, and a
  // re-render will not cover for it because tom-select caches rendered rows -- so after Select all /
  // Unselect all the ticks kept their old state.
  //
  // Read `items`, not the row's `selected` class: the class lands later than these events (the plugin
  // itself waits 1ms for it), and Select all cascades one item_add per option, so a DOM read is a race
  // that measured wrong in both directions. `items` is already updated when the event fires, and the
  // last event of a cascade sees the full set.
  syncMarkers (select) {
    select.dropdown_content.querySelectorAll('.option').forEach((row) => {
      const marker = row.querySelector('.tomselect-checkbox')
      if (!marker) return

      const checked = select.items.includes(row.dataset.value)
      marker.classList.toggle('form-check-input--checked', checked)
      marker.classList.toggle('form-check-input--unchecked', !checked)
    })
  }

  // Wrapped here rather than configured, because the plugin installs its own `render.option` wrapper
  // during `setupTemplates` -- this runs after the constructor, so it wraps the plugin's and sees the
  // injected checkbox. Both selection paths re-render the row (the plugin refreshes on deselect, our
  // onItemAdd refreshes on select), so the swap re-applies with the right classes every time.
  swapCheckboxForMarker (select) {
    const inner = select.settings.render.option

    select.settings.render.option = function (data, escape) {
      const rendered = inner.call(this, data, escape)
      const checkbox = rendered && rendered.querySelector && rendered.querySelector('input.tomselect-checkbox')
      if (checkbox) checkbox.replaceWith(inertMarkerFor(checkbox))
      return rendered
    }
  }
}
