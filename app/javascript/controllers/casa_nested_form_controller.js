// https://www.stimulus-components.com/docs/stimulus-rails-nested-form/
import NestedForm from '@stimulus-components/rails-nested-form'

// TODO: REMOVE THIS SINCE NO LONGER NEEDED?
// Connects to data-controller="casa-nested-form"
export default class extends NestedForm {
  connect () {
    super.connect()
  }

  add = (event) => {
    super.add(event)
  }

  remove = (event) => {
    super.remove(event)
  }
}
