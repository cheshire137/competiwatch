import Taggle from 'taggle'
import SelectorObserver from 'selector-observer'

const observer = new SelectorObserver(document, '#friends-list', function() {
  const options = {
    placeholder: 'List players you grouped with',
    hiddenInputName: 'friend_names[]',
    preserveCase: true,
    saveOnBlur: true
  }
  new Taggle('friends-list', options)
})
observer.observe()

