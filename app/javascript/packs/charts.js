import Chart from 'chart.js'
import SelectorObserver from 'selector-observer'
import {on} from 'delegated-events'
import remoteLoadCharts from './remote-load-charts.js'

const winColor = '#29fd2f'
const transparentWinColor = 'rgba(41,253,47,0.7)'
const lossColor = '#ca0813'
const transparentLossColor = 'rgba(202,8,19,0.7)'
const drawColor = '#fed86f'
const transparentDrawColor = 'rgba(254,216,111,0.7)'

const allyColor = '#299FFD'
const transparentAllyColor = 'rgba(41,159,253,0.7)'
const enemyColor = '#FD9629'
const transparentEnemyColor = 'rgba(253,150,41,0.7)'

on('click', '.js-trends-tab', function(event) {
  remoteLoadCharts()
})

const streaksObserver = new SelectorObserver(document, '.js-streaks-chart', function() {
  const context = this.getContext('2d')
  const options = {}
  const gameNumbers = this.getAttribute('data-game-numbers')
  const winStreaks = this.getAttribute('data-win-streaks')
  const lossStreaks = this.getAttribute('data-loss-streaks')
  const data = {
    labels: JSON.parse(gameNumbers),
    datasets: [
      {
        fill: 'origin',
        label: 'Win Streak',
        backgroundColor: transparentWinColor,
        borderColor: winColor,
        borderWidth: 2,
        data: JSON.parse(winStreaks),
        pointRadius: 0
      },
      {
        fill: 'origin',
        label: 'Loss Streak',
        backgroundColor: transparentLossColor,
        borderColor: lossColor,
        borderWidth: 2,
        data: JSON.parse(lossStreaks),
        pointRadius: 0
      }
    ]
  }
  new Chart(context, { type: 'line', data, options })
})
streaksObserver.observe()

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
        backgroundColor: [transparentWinColor, transparentLossColor, transparentDrawColor],
        borderColor: [winColor, lossColor, drawColor],
        data: [wins, losses, draws]
      }
    ]
  }
  new Chart(context, { type: 'pie', data, options })
})
winLossObserver.observe()

const winLossBarObserver = new SelectorObserver(document, '.js-win-loss-bar-chart', function() {
  const context = this.getContext('2d')
  const options = {
    scales: {
      xAxes: [{ ticks: { autoSkip: false } }]
    }
  }
  const labels = this.getAttribute('data-labels')
  const wins = this.getAttribute('data-wins')
  const losses = this.getAttribute('data-losses')
  const draws = this.getAttribute('data-draws')
  const data = {
    labels: JSON.parse(labels),
    datasets: [
      {
        backgroundColor: transparentWinColor,
        borderColor: winColor,
        borderWidth: 2,
        label: 'Wins',
        data: JSON.parse(wins)
      },
      {
        backgroundColor: transparentLossColor,
        borderColor: lossColor,
        borderWidth: 2,
        label: 'Losses',
        data: JSON.parse(losses)
      },
      {
        backgroundColor: transparentDrawColor,
        borderColor: drawColor,
        borderWidth: 2,
        label: 'Draws',
        data: JSON.parse(draws)
      }
    ]
  }
  new Chart(context, { type: 'bar', data, options })
})
winLossBarObserver.observe()

const throwerLeaverObserver = new SelectorObserver(document, '.js-thrower-leaver-chart', function() {
  const context = this.getContext('2d')
  const options = {}
  const labels = this.getAttribute('data-labels')
  const allies = this.getAttribute('data-allies')
  const enemies = this.getAttribute('data-enemies')
  const data = {
    labels: JSON.parse(labels),
    datasets: [
      {
        backgroundColor: transparentAllyColor,
        borderColor: allyColor,
        borderWidth: 2,
        label: 'My Team',
        data: JSON.parse(allies)
      },
      {
        backgroundColor: transparentEnemyColor,
        borderColor: enemyColor,
        borderWidth: 2,
        label: 'Enemy Team',
        data: JSON.parse(enemies)
      }
    ]
  }
  new Chart(context, { type: 'bar', data, options })
})
throwerLeaverObserver.observe()

const heroesObserver = new SelectorObserver(document, '.js-heroes-chart', function() {
  const context = this.getContext('2d')
  const options = {
    scales: {
      xAxes: [{ ticks: { autoSkip: false } }]
    }
  }
  const labels = this.getAttribute('data-labels')
  const wins = this.getAttribute('data-wins')
  const losses = this.getAttribute('data-losses')
  const draws = this.getAttribute('data-draws')
  const data = {
    labels: JSON.parse(labels),
    datasets: [
      {
        backgroundColor: transparentWinColor,
        borderColor: winColor,
        borderWidth: 2,
        label: 'Wins',
        data: JSON.parse(wins)
      },
      {
        backgroundColor: transparentLossColor,
        borderColor: lossColor,
        borderWidth: 2,
        label: 'Losses',
        data: JSON.parse(losses)
      },
      {
        backgroundColor: transparentDrawColor,
        borderColor: drawColor,
        borderWidth: 2,
        label: 'Draws',
        data: JSON.parse(draws)
      }
    ]
  }
  new Chart(context, { type: 'bar', data, options })
})
heroesObserver.observe()
