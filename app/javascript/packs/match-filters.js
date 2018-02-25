import {on} from 'delegated-events'

on('click', '.js-match-filter', function(event) {
  const button = event.currentTarget
  const classToShow = button.getAttribute('data-filter')
  const menuContainer = button.closest('.js-menu-container')
  menuContainer.classList.toggle('active')

  const filterButtons = menuContainer.querySelectorAll('.js-match-filter')
  for (const filterButton of filterButtons) {
    const isSelected = filterButton.getAttribute('data-filter') === classToShow
    filterButton.classList.toggle('selected', isSelected)
  }

  const matchContainer = document.querySelector('.js-filterable-matches')
  const matches = matchContainer.querySelectorAll('.js-filterable-match')
  const countEl = document.querySelector('.js-filtered-match-count')

  let visibleCount = 0
  for (const match of matches) {
    const showMatch = match.classList.contains(classToShow)
    match.classList.toggle('d-none', !showMatch)
    if (showMatch) {
      visibleCount++
    }
  }

  countEl.textContent = visibleCount
})
