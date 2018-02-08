const isLocalhost = window.location.host.indexOf('localhost') > -1
const isHttps = window.location.protocol === 'https:'

if (!isLocalhost && !isHttps) {
  window.location.href = `https:${window.location.href.substring(window.location.protocol.length)}`
}
