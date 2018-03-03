const preferredHost = 'www.competiwatch.com'
if (preferredHost === window.location.host && window.location.protocol !== 'https:') {
  window.location.protocol = 'https'
}

const otherHost = 'competiwatch.herokuapp.com'
if (otherHost === window.location.host) {
  window.location.href = `https://${preferredHost}${window.location.pathname}`
}
