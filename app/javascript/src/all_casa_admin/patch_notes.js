const Notifier = require('../async_notifier')
const patchNotePage = {
}

$('document').ready(() => {
  const asyncNotificationsElement = $('#async-notifications')
  patchNotePage.notifier = new Notifier(asyncNotificationsElement)

  const newPatchNoteElement = $('#new-patch-note')

  newPatchNoteElement.children('button').click(() => {
    console.log(`Patch Note: ${newPatchNoteElement.children('textarea').val()}`)
    console.log(`Patch Note Group ID: ${$('#new-patch-note-group').val()}`)
    console.log(`Patch Note Type ID: ${$('#new-patch-note-type').val()}`)
  })

  patchNotePage.notifier.notify('test', 'info')
})
