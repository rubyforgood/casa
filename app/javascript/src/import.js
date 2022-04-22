function dataURItoBlob(dataURI) {
  // convert base64 to raw binary data held in a string
  var byteString = atob(dataURI.split(",")[1]);

  // separate out the mime component
  var mimeString = dataURI.split(",")[0].split(":")[1].split(";")[0];

  // write the bytes of the string to an ArrayBuffer
  var arrayBuffer = new ArrayBuffer(byteString.length);
  var _ia = new Uint8Array(arrayBuffer);
  for (var i = 0; i < byteString.length; i++) {
    _ia[i] = byteString.charCodeAt(i);
  }

  var dataView = new DataView(arrayBuffer);
  var blob = new Blob([dataView], { type: mimeString });
  return blob;
}

function storeCSVFile(file, key) {
  var reader = new FileReader();
  reader.onload = (fileEvent) => {
    localStorage[key] = JSON.stringify({
      name: file.name,
      data: fileEvent.target.result,
    });
  };
  reader.readAsDataURL(file);
}

function fetchCSVFile(key) {
  const storedFileData = JSON.parse(localStorage[key]);
  var fileContent = dataURItoBlob(storedFileData.data);
  var file = new File([fileContent], storedFileData.name, { type: "text/csv" });
  return file;
}

function populateFileInput(inputId) {
  const csvInput = document.getElementById(inputId);
  if (csvInput.files.length === 0 && localStorage[inputId]) {
    const file = fetchCSVFile(inputId);
    const container = new DataTransfer();
    container.items.add(file);
    csvInput.files = container.files;
  }
}

$("document").ready(() => {
  document.getElementById("volunteer-file").addEventListener("change", function (event) {
    document.getElementById("volunteer-import-button").disabled = event.target.value == "";
    const file = document.getElementById("volunteer-file").files[0];
    storeCSVFile(file, "volunteer-file");
  });

  document.getElementById("supervisor-file").addEventListener("change", function (event) {
    document.getElementById("supervisor-import-button").disabled = event.target.value == "";
    const file = document.getElementById("supervisor-file").files[0];
    storeCSVFile(file, "supervisor-file");
  });

  if (document.getElementById("smsOptIn") === null) {
    delete localStorage["volunteer-file"];
    delete localStorage["supervisor-file"];
  } else {
    populateFileInput("volunteer-file");
    populateFileInput("supervisor-file");
  }
});
