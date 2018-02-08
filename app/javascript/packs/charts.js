import Chart from 'chart.js'
import SelectorObserver from 'selector-observer'
import {on} from 'delegated-events'
import remoteLoadCharts from './remote-load-charts.js'

on('click', '.js-trends-tab', function(event) {
  remoteLoadCharts()
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

const perMapWinLossObserver = new SelectorObserver(document, '.js-per-map-win-loss-chart', function() {
  const context = this.getContext('2d')
  const options = {
    scales: {
      xAxes: [{ ticks: { autoSkip: false } }]
    }
  }
  const colors = this.getAttribute('data-colors')
  const labels = this.getAttribute('data-labels')
  const wins = this.getAttribute('data-wins')
  const losses = this.getAttribute('data-losses')
  const draws = this.getAttribute('data-draws')
  const data = {
    labels: JSON.parse(labels),
    datasets: [
      {
        backgroundColor: '#ff6384',
        label: 'Wins',
        data: JSON.parse(wins)
      },
      {
        backgroundColor: '#36a2eb',
        label: 'Losses',
        data: JSON.parse(losses)
      },
      {
        backgroundColor: '#ffce56',
        label: 'Draws',
        data: JSON.parse(draws)
      }
    ]
  }
  new Chart(context, { type: 'bar', data, options })
})
perMapWinLossObserver.observe()
