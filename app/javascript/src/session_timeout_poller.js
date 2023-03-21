
const deviseTimeoutInMinutes = 180;
const twoMinuteWarning = deviseTimeoutInMinutes - 2;
const totalTimerAmount = twoMinuteWarning * 60 * 1000;
const deviseTimeoutInMilliseconds = deviseTimeoutInMinutes * 60 * 1000;
const startTime = new Date().getTime();
var lastTime = new Date().getTime();
var timeElapsed;

function warningBoxAndReload() {
  alert("Warning: You will be logged off in 2 minutes due to inactivity.");
  location.reload();
}

setInterval(myTimer, 1000);

function myTimer() {
  timeElapsed = Math.abs(lastTime - startTime);
  currentTime = new Date().getTime();
  // console.log("Should go up by 1 second", timeElapsed);
  
  if (timeElapsed > deviseTimeoutInMilliseconds) {
    location.reload();
  } else if (timeElapsed > totalTimerAmount) {
    warningBoxAndReload();
  } else {
    lastTime = currentTime;  
  }
};
