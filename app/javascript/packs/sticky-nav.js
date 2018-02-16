import SelectorObserver from 'selector-observer'

function setupStickyNav() {
  const nav = document.querySelector('.js-sticky-nav')
  const offset = parseInt(nav.getAttribute('data-original-offset'), 10)
  nav.classList.toggle('sticky-nav', window.pageYOffset >= offset)
}

const observer = new SelectorObserver(document, '.js-sticky-nav', function() {
  const rect = this.getBoundingClientRect()
  this.setAttribute('data-original-offset', rect.x - 8)
  document.addEventListener('scroll', setupStickyNav, { passive: true })
  setupStickyNav()
})
observer.observe()
