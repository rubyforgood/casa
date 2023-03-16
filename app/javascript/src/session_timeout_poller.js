let heartBeatActivated = false;
class HeartBeat {
  constructor() {
    document.addEventListener('DOMContentLoaded', () => {
      this.initHeartBeat();
    });
  }

  initHeartBeat() {
    this.lastActive = new Date().valueOf;
    if (!heartBeatActivated) {
      ['mousemove', 'scroll', 'click', 'keydown'].forEach((activity) => {
        document.addEventListener(activity, (ev) => {
          this.lastActive = ev.timeStamp + PerformanceEntry.startTime;
        }, false);
      });
      heartBeatActivated = true;
    }
  }
}

window.heartBeat = new HeartBeat();

const sessionTimeoutPollFrequency = 5;
function pollForSessionTimeout() {
  if ((Date.now() - window.heartBeat.lastActive) < (sessionTimeoutPollFrequency * 1000)) {
    // setTimeout(pollForSessionTimeout, (sessionTimeoutPollFrequency * 1000));
    return;
  }
  
  let request = new XMLHttpRequest();
  request.onload = function (event) {
    var status = event.target.status;
    var response = event.target.response;
    
    if (status === 200 && (response <= 10790)) {
      alert("2 minutes left");
    }

    // if the remaining valid time for the current user session is less than or equals to 0 seconds.
    if (status === 200 && (response <= 0)) {
      window.location.href = '/session_timeout';
    }
  };
  request.open('GET', '/check_session_timeout', true);
  request.responseType = 'json';
  request.send();
  setTimeout(pollForSessionTimeout, (sessionTimeoutPollFrequency * 1000));
}

setTimeout(pollForSessionTimeout, (sessionTimeoutPollFrequency * 1000));
