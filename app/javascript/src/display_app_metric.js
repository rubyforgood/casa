import { Chart, registerables } from 'chart.js'
import 'chartjs-adapter-luxon'

Chart.register(...registerables)

const days = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday']

$(() => { // JQuery's callback for the DOM loading
  const chartElement = document.getElementById('myChart')

  if (chartElement) {
    $.ajax({
      type: 'GET',
      url: '/health/case_contacts_creation_times_in_last_week',
      success: function (data) {
        const timestamps = data.timestamps
        const counts = getCountsByDayAndHour(timestamps)
        const dataset = getDatasetFromCounts(counts)

        createChart(chartElement, dataset)
      },
      error: function (xhr, status, error) {
        console.error('Failed to fetch data for case contact entry times chart display')
        console.error(error)
        $('#chart-error-message').append(`
          <div class="alert alert-danger" role="alert">
            Failed to display metric chart. Check the console for error details.
          </div>`)
        $('.text-center').hide()
      }
    })
  }
})

function getCountsByDayAndHour (timestamps) {
  const counts = {}

  for (let i = 0; i < timestamps.length; i++) {
    const timestamp = new Date(timestamps[i] * 1000)
    const day = days[timestamp.getUTCDay()]
    const hour = timestamp.getUTCHours()
    const key = day + ' ' + hour
    counts[key] = (counts[key] || 0) + 1
  }

  return counts
}

function getDatasetFromCounts (counts) {
  const dataset = []

  for (const key in counts) {
    const parts = key.split(' ')
    const day = parts[0]
    const hour = parseInt(parts[1])
    const count = counts[key]

    dataset.push({
      x: hour,
      y: days.indexOf(day),
      r: Math.sqrt(count) * 2,
      count
    })
  }

  return dataset
}

function createChart (chartElement, dataset) {
  const ctx = chartElement.getContext('2d')

  return new Chart(ctx, {
    type: 'bubble',
    data: {
      datasets: [
        {
          label: 'Case Contacts Creation Times in Last Week',
          data: dataset,
          backgroundColor: 'rgba(255, 99, 132, 0.2)',
          borderColor: 'rgba(255, 99, 132, 1)'
        }
      ]
    },
    options: getChartOptions()
  })
}

function getChartOptions () {
  return {
    scales: {
      x: getXScale(),
      y: getYScale()
    },
    plugins: {
      tooltip: {
        callbacks: {
          label: getTooltipLabelCallback()
        }
      }
    }
  }
}

function getXScale () {
  return {
    ticks: {
      beginAtZero: true,
      stepSize: 1
    }
  }
}

function getYScale () {
  return {
    ticks: {
      beginAtZero: true,
      stepSize: 1,
      callback: getYTickCallback()
    }
  }
}

function getYTickCallback () {
  return function (value, index, values) {
    return days[value]
  }
}

function getTooltipLabelCallback () {
  return function (context) {
    const datum = context.dataset.data[context.dataIndex]
    return datum.count + ' case contacts created on ' + days[datum.y] + ' at ' + datum.x + ':00'
  }
}
