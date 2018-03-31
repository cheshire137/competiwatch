function setPageTheme() {
  const date = new Date()
  const hours = date.getHours()
  const isNight = hours >= 20 || hours <= 5
  const themeClass = isNight ? 'theme-dark' : 'theme-light'
  document.body.classList.add(themeClass)
}

setPageTheme()
