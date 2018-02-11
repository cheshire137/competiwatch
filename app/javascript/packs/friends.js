import Taggle from 'taggle'
import SelectorObserver from 'selector-observer'

const observer = new SelectorObserver(document, '#friends-list', function() {
  const options = {
    placeholder: 'List players you grouped with',
    hiddenInputName: 'friends[]'
  }
  new Taggle('friends-list', options)
})
observer.observe()

