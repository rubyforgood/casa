import { Chart, registerables } from 'chart.js'
import 'chartjs-adapter-luxon'

const { Notifier } = require('./notifier')

Chart.register(...registerables)

const days = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday']

$(() => { // JQuery's callback for the DOM loading
  const chartElement = document.getElementById('myChart')

  if (chartElement) {
    const notificationsElement = $('#notifications')
    const pageNotifier = notificationsElement.length ? new Notifier(notificationsElement) : null

    $.ajax({
      type: 'GET',
      url: '/health/case_contacts_creation_times_in_last_week',
      success: function (data) {
        const timestamps = data.timestamps
        const graphData = formatData(timestamps)

        createChart(chartElement, graphData)
      },
      error: function (xhr, status, error) {
        console.error('Failed to fetch data for case contact entry times chart display')
        console.error(error)
        pageNotifier?.notify('Failed to display metric chart. Check the console for error details.', 'error')
      }
    })
  }
})

function formatData (timestamps) {
  const bubbleDataAsObject = {}

  for (const timestamp of timestamps) {
    const contactCreationTime = new Date(timestamp * 1000)
    const day = contactCreationTime.getDay()
    const hour = contactCreationTime.getHours()

    // Case contacts with the same hour and day creation time are represented by the same bubble

    let dayData

    if (!(day in bubbleDataAsObject)) {
      dayData = {}
      bubbleDataAsObject[day] = dayData
    } else {
      dayData = bubbleDataAsObject[day]
    }

    if (!(hour in dayData)) {
      dayData[hour] = 1
    } else {
      dayData[hour]++
    }
  }

  const bubbleDataAsArray = []

  for (const day in bubbleDataAsObject) {
    const hours = bubbleDataAsObject[day]

    for (const hour in hours) {
      bubbleDataAsArray.push({
        x: hour,
        y: day,
        r: Math.sqrt(hours[hour]) * 4
      })
    }
  }

  return bubbleDataAsArray
}

function createChart (chartElement, dataset) {
  const ctx = chartElement.getContext('2d')

  return new Chart(ctx, {
    type: 'bubble',
    data: {
      datasets: [
        {
          label: 'Case Contact Creation Times',
          data: dataset,
          backgroundColor: 'rgba(255, 99, 132, 0.2)',
          borderColor: 'rgba(255, 99, 132, 1)'
        }
      ]
    },
    options: {
      scales: {
        x: {
          min: 0,
          max: 23,
          ticks: {
            beginAtZero: true,
            stepSize: 1
          }
        },
        y: {
          min: 0,
          max: 6,
          ticks: {
            beginAtZero: true,
            callback: getYTickCallback,
            stepSize: 1
          }
        }
      },
      plugins: {
        legend: {
          display: false
        },
        title: {
          display: true,
          font: {
            size: 18
          },
          text: 'Case Contact Creation Times in the Past Week'
        },
        tooltip: {
          callbacks: {
            label: getTooltipLabelCallback
          }
        }
      }
    }
  })
}

function getYTickCallback (value) {
  return days[value]
}

function getTooltipLabelCallback (context) {
  const bubbleData = context.dataset.data[context.dataIndex]
  const caseContactCountSqrt = bubbleData.r / 4
  return `${Math.round(caseContactCountSqrt * caseContactCountSqrt)} case contacts created on ${days[bubbleData.y]} at ${bubbleData.x}:00`
}
