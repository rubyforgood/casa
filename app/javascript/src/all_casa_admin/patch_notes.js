const Notifier = require('../async_notifier')
const patchNotePage = {
}

$('document').ready(() => {
  const asyncNotificationsElement = $('#async-notifications')
  patchNotePage.notifier = new Notifier(asyncNotificationsElement)

  const newPatchNoteElement = $('#new-patch-note')
  const newPatchNoteGroupDropdown = $('#new-patch-note-group')
  const newPatchNoteTypeDropdown = $('#new-patch-note-type')

  const disableNewPatchNoteForm = () => {
    newPatchNoteGroupDropdown.prop('disabled', true)
    newPatchNoteTypeDropdown.prop('disabled', true)
  }

  newPatchNoteElement.children('button').click(() => {
    console.log(`Patch Note: ${newPatchNoteElement.children('textarea').val()}`)
    console.log(`Patch Note Group ID: ${newPatchNoteGroupDropdown.val()}`)
    console.log(`Patch Note Type ID: ${newPatchNoteTypeDropdown.val()}`)

    disableNewPatchNoteForm()
  })

  patchNotePage.notifier.notify('test', 'info')
})
