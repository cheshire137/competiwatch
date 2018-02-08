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

const winLossObserver = new SelectorObserver(document, '.js-win-loss-chart', function() {
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
winLossObserver.observe()

const barChartObserver = new SelectorObserver(document, '.js-bar-chart', function() {
  const context = this.getContext('2d')
  const options = {
    scales: {
      xAxes: [{ ticks: { autoSkip: false } }]
    },
    legend: { display: false }
  }
  const colors = this.getAttribute('data-colors')
  const labels = this.getAttribute('data-labels')
  const values = this.getAttribute('data-values')
  const data = {
    labels: JSON.parse(labels),
    datasets: [
      {
        borderColor: 'rgba(0,0,0,0.5)',
        borderWidth: 1,
        backgroundColor: JSON.parse(colors),
        data: JSON.parse(values)
      }
    ]
  }
  new Chart(context, { type: 'bar', data, options })
})
barChartObserver.observe()
