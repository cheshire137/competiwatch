import {on} from 'delegated-events'
import Taggle from 'taggle'
import SelectorObserver from 'selector-observer'

function validateFriends() {
  const inputs = document.querySelectorAll('input[name="friend_names[]"]')
  const selectedFriends = []
  let input
  for (input of inputs) {
    if (input.type === 'hidden') {
      selectedFriends.push(input.value)
    } else if (input.type === 'checkbox' && input.checked) {
      selectedFriends.push(input.value)
    }
  }
  const container = input.closest('.js-friends-container')
  const tooManyFriends = selectedFriends.length > 5
  container.classList.toggle('flash-error', tooManyFriends)
  const messageEl = container.querySelector('.js-max-friends-message')
  messageEl.classList.toggle('d-none', !tooManyFriends)
}

const observer = new SelectorObserver(document, '#friends-list', function() {
  const options = {
    placeholder: 'List other players in your group',
    hiddenInputName: 'friend_names[]',
    preserveCase: true,
    saveOnBlur: true,
    onTagAdd: validateFriends,
    onTagRemove: validateFriends
  }
  new Taggle('friends-list', options)
})
observer.observe()

on('change', 'input[name="friend_names[]"]', validateFriends)
