import {on} from 'delegated-events'

on('click', '.js-carousel-nav-item', function(event) {
  const button = event.currentTarget
  button.blur()

  const nav = button.parentNode
  const activeButton = nav.querySelector('.js-carousel-nav-item.active')
  const carousel = button.closest('.js-carousel')
  const activeImage = carousel.querySelector('.carousel-image.active')
  const image = carousel.querySelector(`.${button.getAttribute('data-target')}`)

  if (activeImage) {
    activeImage.classList.remove('active')
  }
  if (activeButton) {
    activeButton.classList.remove('active')
  }

  image.classList.add('active')
  button.classList.add('active')
})
