import {on} from 'delegated-events'
import Taggle from 'taggle'
import SelectorObserver from 'selector-observer'

function autocompleteFriends(el, taggle) {
  const friends = JSON.parse(el.getAttribute('data-friends'))
  if (friends.length < 1) {
    return
  }

  const input = taggle.getInput()
  const container = taggle.getContainer()

  $(input).autocomplete({
    source: friends,
    appendTo: container,
    classes: { 'ui-autocomplete': 'width-full' },
    position: { at: 'left bottom', of: container },
    select: function(event, data) {
      event.preventDefault()
      if (event.which === 1) {
        taggle.add(data.item.value)
      }
    }
  })
}

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
    onTagRemove: validateFriends,
    tags: JSON.parse(this.getAttribute('data-selected-friends'))
  }
  const taggle = new Taggle('friends-list', options)
  autocompleteFriends(this, taggle)
})
observer.observe()

on('change', 'input[name="friend_names[]"]', validateFriends)
