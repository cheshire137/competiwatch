import SelectorObserver from 'selector-observer'

function setupStickyNav() {
  const nav = document.querySelector('.js-sticky-nav')
  const placeholder = document.querySelector('.js-sticky-nav-placeholder')
  const offset = parseInt(nav.getAttribute('data-original-offset'), 10)
  const isSticky = window.pageYOffset >= offset
  nav.classList.toggle('sticky-nav', isSticky)
  placeholder.classList.toggle('d-none', !isSticky)
}

const observer = new SelectorObserver(document, '.js-sticky-nav', function() {
  const rect = this.getBoundingClientRect()
  this.setAttribute('data-original-offset', rect.top)
  document.addEventListener('scroll', setupStickyNav, { passive: true })
  setupStickyNav()
})
observer.observe()
