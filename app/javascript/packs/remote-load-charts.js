import {loadRemotePartial} from './remote-load.js'

export default function remoteLoadCharts() {
  const chartContainers = document.querySelectorAll('.js-remote-chart')

  for (const container of chartContainers) {
    loadRemotePartial(container)
    container.classList.remove('js-remote-chart')
  }
}
