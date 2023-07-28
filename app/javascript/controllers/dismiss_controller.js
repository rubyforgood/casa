import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = [ 'element' ]

  dismiss(event) {
    event.preventDefault();

    const { id } = event.params;
    document.cookie = `dismiss_${id}=true`;
    this.elementTarget.classList.add('d-none');
  }
}
