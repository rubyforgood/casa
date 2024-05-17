import { Chart, registerables } from 'chart.js'
import 'chartjs-adapter-luxon'

const { Notifier } = require('./notifier')

Chart.register(...registerables)

const days = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday']

$(() => { // JQuery's callback for the DOM loading
  const caseContactCreationTimesBubbleChart = document.getElementById('caseContactCreationTimeBubbleChart')
  const monthLineChart = document.getElementById('monthLineChart')
  const uniqueUsersMonthLineChart = document.getElementById('uniqueUsersMonthLineChart')

  const notificationsElement = $('#notifications')
  const pageNotifier = notificationsElement.length ? new Notifier(notificationsElement) : null

  if (caseContactCreationTimesBubbleChart) {
    fetchDataAndCreateChart('/health/case_contacts_creation_times_in_last_week', caseContactCreationTimesBubbleChart, function (data) {
      const timestamps = data.timestamps
      const graphData = formatTimestampsAsBubbleChartData(timestamps)
      createChart(caseContactCreationTimesBubbleChart, graphData)
    })
  }

  if (monthLineChart) {
    fetchDataAndCreateChart('/health/monthly_line_graph_data', monthLineChart, function (data) {
      console.log(data)
      createLineChartForCaseContacts(monthLineChart, data)
    })
  }

  if (uniqueUsersMonthLineChart) {
    fetchDataAndCreateChart('/health/monthly_unique_users_graph_data', uniqueUsersMonthLineChart, function (data) {
      console.log(data)
      createLineChartForUniqueUsersMonthly(uniqueUsersMonthLineChart, data)
    })
  }

  function fetchDataAndCreateChart (url, chartElement, successCallback) {
    $.ajax({
      type: 'GET',
      url,
      success: successCallback,
      error: handleAjaxError
    })
  }

  function handleAjaxError (xhr, status, error) {
    console.error('Failed to fetch data for case contact entry times chart display')
    console.error(error)
    pageNotifier?.notify('Failed to display metric chart. Check the console for error details.', 'error')
  }
})

function formatTimestampsAsBubbleChartData (timestamps) {
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

function createLineChartForCaseContacts (chartElement, dataset) {
  const datasetLabels = ['Total Case Contacts', 'Total Case Contacts with Notes', 'Total Case Contact Users']
  return createLineChart(chartElement, dataset, 'Case Contact Creation', datasetLabels)
}

function createLineChartForUniqueUsersMonthly (chartElement, dataset) {
  const datasetLabels = ['Total Volunteers', 'Total Supervisors', 'Total Admins']
  return createLineChart(chartElement, dataset, 'Monthly Active Users', datasetLabels)
}

function createLineChart (chartElement, dataset, chartTitle, datasetLabels) {
  const ctx = chartElement.getContext('2d')
  const allMonths = extractChartData(dataset, 0)
  const datasets = []
  const colors = ['#308af3', '#48ba16', '#FF0000']

  for (let i = 1; i < dataset[0].length; i++) {
    const data = extractChartData(dataset, i)
    const label = datasetLabels[i - 1]
    const color = colors[i - 1]
    datasets.push(createLineChartDataset(label, data, color, color))
  }

  return new Chart(ctx, {
    type: 'line',
    data: {
      labels: allMonths,
      datasets
    },
    options: createChartOptions(chartTitle)
  })
}

function extractChartData (dataset, index) {
  return dataset.map(data => data[index])
}

function createLineChartDataset (label, data, borderColor, pointBackgroundColor) {
  return {
    label,
    data,
    fill: false,
    borderColor,
    pointBackgroundColor,
    pointBorderWidth: 2,
    pointHoverBackgroundColor: '#fff',
    pointHoverBorderWidth: 2,
    lineTension: 0.05
  }
}

function createChartOptions (label) {
  return {
    legend: { display: true },
    plugins: {
      legend: { display: true, position: 'bottom' },
      title: {
        display: true,
        font: { size: 18 },
        text: label
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
}
