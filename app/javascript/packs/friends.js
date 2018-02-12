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

const observer = new SelectorObserver(document, '#friends-list', function() {
  const options = {
    placeholder: 'List players you grouped with',
    hiddenInputName: 'friend_names[]',
    preserveCase: true,
    saveOnBlur: true,
    tags: JSON.parse(this.getAttribute('data-selected-friends'))
  }
  const taggle = new Taggle('friends-list', options)
  autocompleteFriends(this, taggle)
})
observer.observe()

