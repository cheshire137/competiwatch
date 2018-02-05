import {on} from 'delegated-events'

on('click', '.js-log-match-tab', function() {
  const timeSelect = document.getElementById('match_time_of_day')
  const daySelect = document.getElementById('match_day_of_week')
  const date = new Date()
  const dayOfWeek = date.getDay()
  const hours = date.getHours()
  const isWeekend = dayOfWeek === 0 || dayOfWeek === 6

  if (isWeekend) {
    daySelect.value = 'weekend'
  } else {
    daySelect.value = 'weekday'
  }

  if (hours >= 5 && hours < 12) {
    timeSelect.value = 'morning'
  } else if (hours >= 12 && hours < 5) {
    timeSelect.value = 'afternoon'
  } else if (hours >= 5 && hours < 9) {
    timeSelect.value = 'evening'
  } else {
    timeSelect.value = 'night'
  }
})
