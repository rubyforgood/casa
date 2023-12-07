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

  const monthLineChart = document.getElementById('monthLineChart')

  if (monthLineChart) {
    const notificationsElement = $('#notifications')
    const pageNotifier = notificationsElement.length ? new Notifier(notificationsElement) : null

    $.ajax({
      type: 'GET',
      url: '/health/case_contacts_creation_times_in_last_year',
      success: function (data) {
        console.log(data)
        createLineChart(monthLineChart, data)
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

    // Group case contacts with the same hour and day creation time into the same data point

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

  // Flatten data points

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

function createLineChart (chartElement, dataset) {
  const ctx = chartElement.getContext('2d')

  const allMonths = dataset.map(([month]) => month)
  const allCaseContactsCount = dataset.map(([_, caseContactsCount]) => caseContactsCount)
  const allCaseContactNotesCount = dataset.map(([_, __, caseContactNotesCount]) => caseContactNotesCount)
  const allUsersCount = dataset.map(([, , , usersCount]) => usersCount)

  return new Chart(ctx, {
    type: 'line',
    data: {
      labels: allMonths,
      datasets: [{
        label: 'Total Case Contacts',
        data: allCaseContactsCount,
        fill: false,
        borderColor: '#308af3',
        pointBackgroundColor: '#308af3',
        pointBorderWidth: 2,
        pointHoverBackgroundColor: '#fff',
        pointHoverBorderWidth: 2,
        lineTension: 0.05
      }, {
        label: 'Total Case Contacts with Notes',
        data: allCaseContactNotesCount,
        fill: false,
        borderColor: '#48ba16',
        pointBackgroundColor: '#48ba16',
        pointBorderWidth: 2,
        pointHoverBackgroundColor: '#fff',
        pointHoverBorderWidth: 2,
        lineTension: 0.05
      }, {
        label: 'Total Users',
        data: allUsersCount,
        fill: false,
        borderColor: '#FF0000',
        pointBackgroundColor: '#FF0000',
        pointBorderWidth: 2,
        pointHoverBackgroundColor: '#fff',
        pointHoverBorderWidth: 2,
        lineTension: 0.05
      }]
    },
    options: {
      legend: { display: true },
      plugins: {
        legend: {
          display: true,
          position: 'bottom'
        },
        title: {
          display: true,
          font: {
            size: 18
          },
          text: 'Case Contact Creation Times in last 12 months'
        },
        tooltips: {
          callbacks: {
            label: function (tooltipItem, data) {
              let label = data.datasets[tooltipItem.datasetIndex].label || ''
              if (label) {
                label += ': '
              }
              label += Math.round(tooltipItem.yLabel * 100) / 100
              return label
            }
          }
        }
      }
    }
  })
}
