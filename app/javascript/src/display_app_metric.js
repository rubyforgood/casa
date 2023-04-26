import { Chart, registerables } from 'chart.js'
import 'chartjs-adapter-luxon'

Chart.register(...registerables)

$(document).ready(function() {
  $.ajax({
    type: 'GET',
    url: '/case_contacts/case_contacts_creation_times_in_last_week',
    success: handleResponse,
    error: function(xhr, status, error) {
      // handle any errors here
    }
  })
})

function handleResponse(data) {
  const counts = getCountsByDayAndHour(data.timestamps)
  const dataset = createDatasetFromCounts(counts)
  createChart(dataset)
}

function getCountsByDayAndHour(timestamps) {
  const days = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday']
  const counts = {}
  for (let i = 0; i < timestamps.length; i++) {
    const timestamp = new Date(timestamps[i] * 1000)
    const day = days[timestamp.getUTCDay()]
    const hour = timestamp.getUTCHours()
    const key = day + ' ' + hour
    if (key in counts) {
      counts[key] += 1
    } else {
      counts[key] = 1
    }
  }
  return counts
}

function createDatasetFromCounts(counts) {
  const dataset = []
  for (const key in counts) {
    const parts = key.split(' ')
    const day = parts[0]
    const hour = parseInt(parts[1])
    dataset.push({
      x: hour,
      y: days.indexOf(day),
      r: Math.sqrt(counts[key]) * 2,
      count: counts[key]
    })
  }
  return dataset
}

function createChart(dataset) {
  const ctx = document.getElementById('myChart').getContext('2d')
  const chart = new Chart(ctx, {
    type: 'bubble',
    data: {
      datasets: [{
        label: 'Case Contacts Creation Times in Last Week',
        data: dataset,
        backgroundColor: 'rgba(255, 99, 132, 0.2)',
        borderColor: 'rgba(255, 99, 132, 1)'
      }]
    },
    options: {
      scales: {
        x: {
          ticks: {
            beginAtZero: true,
            stepSize: 1
          }
        },
        y: {
          ticks: {
            beginAtZero: true,
            stepSize: 1,
            callback: function(value, index, values) {
              const days = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday']
              return days[value]
            }
          }
        }
      },
      plugins: {
        tooltip: {
          callbacks: {
            label: function(context) {
              const days = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday']
              const datum = context.dataset.data[context.dataIndex]
              return datum.count + ' case contacts created on ' + days[datum.y] + ' at ' + datum.x + ':00'
            }
          }
        }
      }
    }
  })
}

function getCountsByDayAndHour(timestamps) {
  const counts = {}
  for (let i = 0; i < timestamps.length; i++) {
    const timestamp = new Date(timestamps[i] * 1000)
    const day = timestamp.getUTCDay()
    const hour = timestamp.getUTCHours()
    const key = `${day} ${hour}`
    counts[key] = (counts[key] || 0) + 1
  }
  return counts
}

function createDatasetFromCounts(counts) {
  const dataset = []
  for (const key in counts) {
    const [dayIndex, hour] = key.split(' ')
    const count = counts[key]
    dataset.push({
      x: Number(hour),
      y: Number(dayIndex),
      r: Math.sqrt(count) * 2,
      count
    })
  }
  return dataset
}
