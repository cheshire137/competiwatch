import {loadRemotePartial} from './remote-load.js'

export default function remoteLoadContent() {
  const containers = document.querySelectorAll('.js-remote-content')

  for (const container of containers) {
    loadRemotePartial(container)
    container.classList.remove('js-remote-content')
  }
}
