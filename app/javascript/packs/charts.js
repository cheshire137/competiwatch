import Chart from 'chart.js'
import SelectorObserver from 'selector-observer'
import {on} from 'delegated-events'
import {loadRemotePartial} from './remote-load.js'

on('click', '.js-trends-tab', function(event) {
  const chartContainers = document.querySelectorAll('.js-remote-chart')

  for (const container of chartContainers) {
    loadRemotePartial(container)
    container.classList.remove('js-remote-chart')
  }
})

const observer = new SelectorObserver(document, '.js-win-loss-chart', function() {
  const context = this.getContext('2d')
  const options = {}
  const wins = this.getAttribute('data-wins')
  const losses = this.getAttribute('data-losses')
  const draws = this.getAttribute('data-draws')
  const data = {
    labels: ['Wins', 'Losses', 'Draws'],
    datasets: [
      {
        backgroundColor: ['#ff6384', '#36a2eb', '#ffce56'],
        data: [wins, losses, draws]
      }
    ]
  }
  new Chart(context, { type: 'pie', data, options })
})
