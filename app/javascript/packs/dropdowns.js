import {on} from 'delegated-events'

on('click', '.js-menu-target', function(event) {
  const button = event.currentTarget
  const container = button.closest('.js-menu-container')
  container.classList.toggle('active')
})

document.addEventListener('click', function(event) {
  const activeMenus = Array.from(document.querySelectorAll('.js-menu-container.active'))
  if (activeMenus.length < 1) {
    return
  }

  const clickedEl = event.target
  const menuContainer = clickedEl.closest('.js-menu-container')

  for (const activeMenu of activeMenus) {
    if (activeMenu.closest('.js-menu-container') !== menuContainer) {
      activeMenu.classList.remove('active')
    }
  }
})
