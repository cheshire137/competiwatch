import {on} from 'delegated-events'

on('click', '.js-tab', function(event) {
  const link = event.target
  const selector = link.getAttribute('href')
  if (selector.indexOf('#') !== 0) {
    return
  }

  event.preventDefault()
  const tabContent = document.querySelector(selector)
  const container = link.closest('.js-tab-container')

  const otherLinks = container.querySelectorAll('.js-tab')
  for (const otherLink of otherLinks) {
    otherLink.classList.remove('selected')
  }

  const otherTabContents = container.querySelectorAll('.js-tab-contents')
  for (const otherTabContent of otherTabContents) {
    otherTabContent.classList.add('d-none')
  }

  tabContent.classList.remove('d-none')
  link.classList.add('selected')
})
