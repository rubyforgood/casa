/* global atob */
/* global Blob */
/* global FileReader */
/* global localStorage */
/* global File */
/* global DataTransfer */
/* global $ */

function dataURItoBlob (dataURI) {
  // convert base64 to raw binary data held in a string
  const byteString = atob(dataURI.split(',')[1])

  // separate out the mime component
  const mimeString = dataURI.split(',')[0].split(':')[1].split(';')[0]

  // write the bytes of the string to an ArrayBuffer
  const arrayBuffer = new ArrayBuffer(byteString.length)
  const _ia = new Uint8Array(arrayBuffer)
  for (let i = 0; i < byteString.length; i++) {
    _ia[i] = byteString.charCodeAt(i)
  }

  const dataView = new DataView(arrayBuffer)
  const blob = new Blob([dataView], { type: mimeString })
  return blob
}

function storeCSVFile (file, key) {
  const reader = new FileReader()
  reader.onload = (fileEvent) => {
    localStorage[key] = JSON.stringify({
      name: file.name,
      data: fileEvent.target.result
    })
  }
  reader.readAsDataURL(file)
}

function fetchCSVFile (key) {
  const storedFileData = JSON.parse(localStorage[key])
  const fileContent = dataURItoBlob(storedFileData.data)
  const file = new File([fileContent], storedFileData.name, { type: 'text/csv' })
  return file
}

function populateFileInput (inputId) {
  const csvInput = document.getElementById(inputId)
  if (csvInput.files.length === 0 && localStorage[inputId]) {
    const file = fetchCSVFile(inputId)
    const container = new DataTransfer()
    container.items.add(file)
    csvInput.files = container.files
  }
}

$(() => { // JQuery's callback for the DOM loading
  ['volunteer', 'supervisor'].forEach((importType) => {
    const inputFileElementId = `${importType}-file`
    const inputFileElement = $(`#${inputFileElementId}`)[0]
    const importButtonElement = $(`#${importType}-import-button`)[0]

    if (inputFileElement && importButtonElement) {
      inputFileElement.addEventListener('change', function (event) {
        importButtonElement.disabled = event.target.value === ''
        const file = inputFileElement.files[0]
        storeCSVFile(file, inputFileElementId)
      })

      if ($('#smsOptIn') == null) {
        delete localStorage[inputFileElementId]
      } else {
        populateFileInput(inputFileElementId)
      }
    }
  })
})
