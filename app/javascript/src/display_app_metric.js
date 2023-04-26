import { Chart, registerables } from 'chart.js';
import 'chartjs-adapter-luxon';

Chart.register(...registerables);

$(document).ready(function() {
  $.ajax({
    type: 'GET',
    url: '/case_contacts/case_contacts_creation_times_in_last_week',
    success: function(data) {
      // handle the response data here
      // extract the timestamps array from the response data
      var timestamps = data.timestamps;
      
      var dataset = [];
      var days = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
      var counts = {};
      for (var i = 0; i < timestamps.length; i++) {
        var timestamp = new Date(timestamps[i] * 1000);
        var day = days[timestamp.getUTCDay()];
        var hour = timestamp.getUTCHours();
        var key = day + ' ' + hour;
        if (key in counts) {
          counts[key] += 1;
        } else {
          counts[key] = 1;
        }
      }
      for (var key in counts) {
        var parts = key.split(' ');
        var day = parts[0];
        var hour = parseInt(parts[1]);
        dataset.push({
          x: hour,
          y: days.indexOf(day),
          r: Math.sqrt(counts[key]) * 2,
          count: counts[key]
        });
      }
      
      // create a chart with Chart.js
      var ctx = document.getElementById('myChart').getContext('2d');
      var chart = new Chart(ctx, {
        type: 'bubble',
        data: {
          datasets: [{
            label: 'Case Contacts Creation Times in Last Week',
            data: dataset,
            backgroundColor: 'rgba(255, 99, 132, 0.2)',
            borderColor: 'rgba(255, 99, 132, 1)',
          }]
        },
        options: {
          scales: {
            x: {
              ticks: {
                beginAtZero: true,
                stepSize: 1,
              }
            },
            y: {
              ticks: {
                beginAtZero: true,
                stepSize: 1,
                callback: function(value, index, values) {
                  return days[value];
                }
              }
            }
          },
          plugins: {
            tooltip: {
              callbacks: {
                label: function(context) {
                  var datum = context.dataset.data[context.dataIndex];
                  return datum.count + ' case contacts created on ' + days[datum.y] + ' at ' + datum.x + ':00';
                }
              }
            }
          }
        }
      });
    }
  });
});
