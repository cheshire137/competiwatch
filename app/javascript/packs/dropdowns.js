import {on} from 'delegated-events'

on('click', '.js-menu-target', function(event) {
  const button = event.currentTarget
  const container = button.closest('.js-menu-container')
  container.classList.toggle('active')
})
