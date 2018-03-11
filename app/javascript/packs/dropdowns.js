import {on} from 'delegated-events'

function menuContainerFor(clickedEl) {
  const menuToggle = clickedEl.closest('.js-menu-target')
  if (!menuToggle) {
    return
  }

  if (menuToggle.hasAttribute('data-target')) {
    const selector = menuToggle.getAttribute('data-target')
    return document.querySelector(selector)
  }

  return menuToggle.closest('.js-menu-container')
}

on('click', '.js-menu-target', function(event) {
  const button = event.currentTarget
  const container = menuContainerFor(button)
  container.classList.toggle('active')
})

document.addEventListener('click', function(event) {
  const activeMenuContainers = Array.from(document.querySelectorAll('.js-menu-container.active'))
  if (activeMenuContainers.length < 1) {
    return
  }

  const clickedEl = event.target
  const menuContainer = menuContainerFor(clickedEl)

  for (const activeMenuContainer of activeMenuContainers) {
    if (activeMenuContainer !== menuContainer) {
      activeMenuContainer.classList.remove('active')
    }
  }
})
