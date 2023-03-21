
const deviseTimeoutInMinutes = 3;
const twoMinuteWarning = deviseTimeoutInMinutes - 2;
const totalTimerAmount = twoMinuteWarning * 20 * 1000;
const deviseTimeoutInMilliseconds = deviseTimeoutInMinutes * 60 * 1000;
const startTime = new Date().getTime();
var lastTime = new Date().getTime();
var timeElapsed;
// var currentTime;

function warningBoxAndReload() {
  alert("Warning: You will be logged off in 2 minutes due to inactivity.");
  location.reload();
}

// setTimeout(warningBoxAndReload, (twoMinuteWarning * 30 * 1000) - timeElapsed));
setInterval(myTimer, 1000);

function myTimer() {
  // timeElapsed = Math.abs(timeElapsed + lastTime);
  timeElapsed = Math.abs(lastTime - startTime);
  // var totalTimeElapsed = timeElapsed - startTime;
  currentTime = new Date().getTime();

  // var totalTimeElapsed = Math.abs(timeElapsed - startTime);
  // var totalTimeElapsed = startTime.getMilliseconds();
  // var totalTimeElapsed = timeElapsed - startTime;
  console.log("Should go up by 1 second", timeElapsed);
  // console.log("Should start at 0 and go up by 1 second", totalTimeElapsed);
  // console.log("Total plus the other", totalTimeElapsed += timeElapsed);

  // console.log("Time since it started", totalTimeElapsed);


  // let timeElapsed = Math.abs(lastTime.getMilliseconds() - currentTime.getMilliseconds());
  if (timeElapsed > totalTimerAmount) {
    location.reload();
  } else if (timeElapsed > totalTimerAmount) {
    warningBoxAndReload();
  } else {
    lastTime = currentTime;  
  }

  
};




// var x = new Date("Aug 12, 2022 19:45:25");
// var y = new Date("Aug 14, 2022 19:45:25");
// let seconds = Math.abs(x.getTime() - y.getTime())/1000;

// var x = new Date("Aug 12, 2022 19:45:25");
// var y = new Date("Aug 14, 2022 19:45:25");
// let timeElapsed = Math.abs(x.getTime() - y.getTime());

// (function($){

//   var TIMEOUT = 20000;
//   var lastTime = (new Date()).getTime();
  
//   setInterval(function() {
//     var currentTime = (new Date()).getTime();
//     if (currentTime > (lastTime + TIMEOUT + 2000)) {
//       $(document).wake();
//     }
    
//     const timeElapsed = Math.abs(lastTime.getTime() - currentTime.getTime());
//     lastTime = currentTime;
//   }, TIMEOUT);
  
//   $.fn.wake = function(callback) {
//     if (typeof callback === 'function') {
//       return $(this).on('wake', callback);
//     } else {
//       return $(this).trigger('wake');
//     }
//   };
  
//   })(jQuery);

//   $(document).on('wake', setTimeout(warningBoxAndReload, (twoMinuteWarning * 30 * 1000) - timeElapsed));

// setInterval(function(){}, 5 * 1000)
// let lastTime = (new Date()).getTime();