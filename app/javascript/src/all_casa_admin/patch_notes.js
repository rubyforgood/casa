const Notifier = require('../async_notifier')
const patchNotePage = {
}

$('document').ready(() => {
  const asyncNotificationsElement = $('#async-notifications')
  patchNotePage.notifier = new Notifier(asyncNotificationsElement)

  patchNotePage.notifier.notify('test', 'info')
})
