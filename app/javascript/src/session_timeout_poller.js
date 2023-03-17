
const deviseTimeoutInMinutes = 180;
const twoMinuteWarning = deviseTimeoutInMinutes - 2;

setTimeout(warningBoxAndReload, twoMinuteWarning * 60 * 1000);
 
function warningBoxAndReload() {
  alert("Warning: You will be logged off in 2 minutes due to inactivity.");
  location.reload();
}
