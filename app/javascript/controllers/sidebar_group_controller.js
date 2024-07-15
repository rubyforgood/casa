import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['title', 'list', 'link']

  connect () {
    this.toggleShow()
    if (this.isEditOrganization()) {
      this.toggleShowAnchorList()
      this.obsFunc()
    }
  }

  // Expands list if a link is active
  toggleShow () {
    this.linkTargets.forEach((link) => {
      if (link.classList.contains('active')) {
        this.titleTarget.classList.remove('collapsed')
        this.listTarget.classList.add('show')
      }
    })
  }

  // For group list with anchor links where method above does not work because 
  // active does not get triggered in sidebar_helper.rb
  toggleShowAnchorList () {
    this.titleTarget.classList.remove('collapsed')
    this.listTarget.classList.add('show')
  }

  obsFunc () {
    console.log('obsFunc is run!')
    let anchorLinks = [];
    this.linkTargets.forEach((link) => {
      if (link.children[0].href.includes('/casa_org/1/edit#')) {
        anchorLinks.push(link);
      }
    });

    const observer = new IntersectionObserver(entries => {
      entries.forEach(entry => {
        if (entry.intersectionRatio > 0) {
          let headerID = entry.target.id
          this.linkTargets.forEach((link) => {
            if (link.children[0].href.includes(headerID)) {
              link.classList.add('active');
            } else {
              link.classList.remove('active');
            }
          })
        }
      });
    });
  
    document.querySelectorAll('h1[id], h2[id]').forEach((header) => {
      observer.observe(header);
    });
  }


  isEditOrganization () {
    let currentPath = window.location.pathname
    return (currentPath == "/casa_org/1/edit" && this.titleTarget.innerText == "Edit Organization");
  }
}
