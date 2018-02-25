import {on} from 'delegated-events'

on('click', '.js-match-filter', function(event) {
  const button = event.currentTarget
  const classToShow = button.getAttribute('data-filter')
  const classPrefix = button.getAttribute('data-filter-prefix')
  const menuContainer = button.closest('.js-menu-container')
  menuContainer.classList.toggle('active')

  let activeClasses = [classToShow]
  if (classToShow !== 'js-filterable-match') {
    const otherClasses = (menuContainer.getAttribute('data-active-filters') || '').
      split(' ').filter(cls => cls.length > 0 && cls.indexOf(classPrefix) < 0)
    activeClasses = activeClasses.concat(otherClasses)
  }
  menuContainer.setAttribute('data-active-filters', activeClasses.join(' '))

  const filterButtons = menuContainer.querySelectorAll('.js-match-filter')
  for (const filterButton of filterButtons) {
    const isSelected = activeClasses.indexOf(filterButton.getAttribute('data-filter')) > -1
    filterButton.classList.toggle('selected', isSelected)
  }

  const matchContainer = document.querySelector('.js-filterable-matches')
  const matches = matchContainer.querySelectorAll('.js-filterable-match')
  const countEl = document.querySelector('.js-filtered-match-count')

  let visibleCount = 0
  for (const match of matches) {
    let showMatch = true
    for (const filterClass of activeClasses) {
      showMatch = showMatch && match.classList.contains(filterClass)
      if (!showMatch) {
        break
      }
    }
    match.classList.toggle('d-none', !showMatch)
    if (showMatch) {
      visibleCount++
    }
  }

  countEl.textContent = visibleCount
})
