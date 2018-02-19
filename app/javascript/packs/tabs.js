import {on} from 'delegated-events'
import remoteLoadContent from './remote-load-content.js'

function activateTab(link, tabContent) {
  const otherLinks = document.querySelectorAll('.js-tab')
  const otherTabContents = document.querySelectorAll('.js-tab-contents')

  for (const otherLink of otherLinks) {
    otherLink.classList.remove('selected')
  }

  for (const otherTabContent of otherTabContents) {
    otherTabContent.classList.add('d-none')
  }

  tabContent.classList.remove('d-none')
  link.classList.add('selected')

  if (link.classList.contains('js-trends-tab')) {
    remoteLoadContent()
  }

  setTimeout(function() {
    if (typeof document.scrollIntoView === 'function') {
      document.scrollIntoView({ behavior: 'smooth', block: 'start', inline: 'nearest' })
    } else {
      const header = document.querySelector('.js-top-nav')
      window.scroll({ top: header.clientHeight, left: 0, behavior: 'smooth' })
    }
  }, 100)
}

on('click', '.js-tab', function(event) {
  const link = event.currentTarget
  const selector = link.getAttribute('href')
  if (selector && selector.indexOf('#') !== 0) {
    return
  }

  const tabContent = document.querySelector(selector)
  activateTab(link, tabContent)
})

function loadTabFromUrl() {
  const tabID = (window.location.hash || '').replace(/^#/, '')
  const tabContent = document.getElementById(tabID)
  const link = document.querySelector(`.js-tab[href="#${tabID}"]`)
  if (!tabContent || !link) {
    return
  }

  activateTab(link, tabContent)
}
loadTabFromUrl()
