class addFields {
  constructor() {
    this.links = document.querySelectorAll('.add_fields');
    console.log('second');
    this.iterateLinks();
  }

  iterateLinks() {
    console.log("hello");
    if (this.links.length === 0) return;
    this.links.forEach(link => {
      link.addEventListener('click', e => {
        this.handleClick(link, e);
      });
    });
  }

  handleClick(link, e) {
    if (!link || !e) return
    e.preventDefault();
    console.log('click')
    let time = new Date().getTime();
    let linkId = link.dataset.id;
    let regexp = linkId ? new RegExp(linkId, 'g') : null;
    let newFields = regexp ? link.dataset.fields.replace(regexp, time) : null;
    newFields ? link.insertAdjacentHTML('beforebegin', newFields) : null;
  }

}

window.addEventListener('turbolinks:load', () => new addFields());
console.log('start');