import {on} from 'delegated-events'

on('click', 'button[data-confirm]', function(event) {
  const button = event.currentTarget
  const message = button.getAttribute('data-confirm')
  if (!window.confirm(message)) {
    event.preventDefault()
  }
})
