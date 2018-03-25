import {on} from 'delegated-events'

function selectTimeAndDay() {
  const timeSelect = document.getElementById('match_time_of_day')
  if (!timeSelect) {
    return
  }
  if (timeSelect.classList.contains('js-no-update')) {
    return
  }

  const daySelect = document.getElementById('match_day_of_week')
  if (daySelect.classList.contains('js-no-update')) {
    return
  }
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
  } else if (hours >= 12 && hours < 17) {
    timeSelect.value = 'afternoon'
  } else if (hours >= 17 && hours < 21) {
    timeSelect.value = 'evening'
  } else {
    timeSelect.value = 'night'
  }
}

on('click', '.js-log-match-tab', selectTimeAndDay)
selectTimeAndDay()
