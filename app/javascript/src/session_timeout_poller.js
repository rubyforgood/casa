const deviseTimeoutInMinutes = 180
const timeoutDuration = 180;
// I could do this below if this is preferred
// const deviseTimeoutInMinutes = timeoutDuration || 180;
const twoMinuteWarning = deviseTimeoutInMinutes - 2
const totalTimerAmount = twoMinuteWarning * 60 * 1000
const deviseTimeoutInMilliseconds = deviseTimeoutInMinutes * 60 * 1000
// config.timeout_in = 3.hours
const startTime = new Date().getTime()
let lastTime = new Date().getTime()
let currentTime
let timeElapsed

function warningBoxAndReload () {
  window.alert('Warning: You will be logged off in 2 minutes due to inactivity.')
  window.location.reload()
}

setInterval(myTimer, 1000)

function myTimer () {
  timeElapsed = Math.abs(lastTime - startTime)
  currentTime = new Date().getTime()
  // console.log('Should go up by 1 second', timeElapsed)
  if (timeElapsed > deviseTimeoutInMilliseconds) {
    window.location.reload()
  } else if (timeElapsed > totalTimerAmount) {
    warningBoxAndReload()
  } else {
    lastTime = currentTime
  }
};
