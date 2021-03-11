document.addEventListener('DOMContentLoaded', () => {
  document.addEventListener('click', (event) => {
    if (event.target.matches('.js-read-more')) {
      return handleReadMore(event)
    }

    if (event.target.matches('.js-read-less')) {
      return handleReadLess(event)
    }
  })
})

const handleReadMore = (event) => {
  event.preventDefault()

  const wrapper = event.target.closest('.js-read-more-text-wrapper')
  wrapper.querySelector('.js-full-text').style.display = 'block'
  wrapper.querySelector('.js-truncated-text').style.display = 'none'
}

const handleReadLess = (event) => {
  event.preventDefault()

  const wrapper = event.target.closest('.js-read-more-text-wrapper')
  wrapper.querySelector('.js-truncated-text').style.display = 'block'
  wrapper.querySelector('.js-full-text').style.display = 'none'
}
