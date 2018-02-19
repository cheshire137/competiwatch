import {on} from 'delegated-events'

on('click', '.js-toggle-details', function(event) {
  event.preventDefault()

  const button = event.currentTarget
  button.blur()

  const targetSelector = button.getAttribute('data-target')
  const targets = document.querySelectorAll(targetSelector)

  const icon = button.querySelector('.ion-chevron-right') || button.querySelector('.ion-chevron-down')
  if (icon) {
    icon.classList.toggle('ion-chevron-right')
    icon.classList.toggle('ion-chevron-down')
  }

  for (const target of targets) {
    target.classList.toggle('d-none')
  }
})
