import {on} from 'delegated-events'

on('click', '.js-match-filter', function(event) {
  const button = event.currentTarget
  const menuContainer = button.closest('.js-menu-container')
  menuContainer.classList.toggle('active')

  const classToShow = button.getAttribute('data-filter')
  const matchContainer = document.querySelector('.js-filterable-matches')
  const matches = matchContainer.querySelectorAll('.js-filterable-match')
  for (const match of matches) {
    match.classList.toggle('d-none', !match.classList.contains(classToShow))
  }
})
