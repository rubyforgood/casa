(() => {
  var __getOwnPropNames = Object.getOwnPropertyNames;
  var __commonJS = (cb, mod) => function __require() {
    return mod || (0, cb[__getOwnPropNames(cb)[0]])((mod = { exports: {} }).exports, mod), mod.exports;
  };

  // app/javascript/src/all_casa_admin/tables.js
  var require_tables = __commonJS({
    "app/javascript/src/all_casa_admin/tables.js"() {
      $(() => {
        if ($("table.admin-list").length > 0) {
          $("table.admin-list").DataTable({ searching: true, order: [[0, "asc"]] });
        }
        if ($("table.organization-list").length > 0) {
          $("table.organization-list").DataTable({ searching: true, order: [[0, "asc"]] });
        }
      });
    }
  });

  // app/javascript/src/type_checker.js
  var require_type_checker = __commonJS({
    "app/javascript/src/type_checker.js"(exports, module) {
      module.exports = {
        // Checks if a variable is a JQuery object
        //  @param  {any}    variable The variable to be checked
        //  @param  {string} varName  The name of the variable to be checked
        //  @throws {TypeError} If variable is not a JQuery object
        //  @throws {ReferenceError} If variable is a JQuery object but points to no elements
        checkNonEmptyJQueryObject(variable, varName) {
          if (!(variable instanceof jQuery)) {
            throw new TypeError(`Param ${varName} must be a jQuery object`);
          }
          if (!variable.length) {
            throw new ReferenceError(`Param ${varName} contains no elements`);
          }
        },
        // Checks if a variable is a non empty string
        //  @param  {any}    variable The variable to be checked
        //  @param  {string} varName  The name of the variable to be checked
        //  @throws {TypeError} If variable is not a string
        //  @throws {RangeError} If variable is empty string
        checkNonEmptyString(variable, varName) {
          this.checkNonEmptyString(variable, varName);
          if (!variable.length) {
            throw new RangeError(`Param ${varName} cannot be empty string`);
          }
        },
        // Checks if a variable is an object
        //  @param  {any}    variable The variable to be checked
        //  @param  {string} varName  The name of the variable to be checked
        //  @throws {TypeError}  If variable is not an object
        checkObject(variable, varName) {
          if (typeof variable !== "object" || Array.isArray(variable) || variable === null) {
            throw new TypeError(`Param ${varName} is not an object`);
          }
        },
        // Checks if a variable is a positive integer
        //  @param  {any}    variable The variable to be checked
        //  @param  {string} varName  The name of the variable to be checked
        //  @throws {TypeError}  If variable is not an integer
        //  @throws {RangeError} If variable is less than 0
        checkPositiveInteger(variable, varName) {
          if (!Number.isInteger(variable)) {
            throw new TypeError(`Param ${varName} is not an integer`);
          } else if (variable < 0) {
            throw new RangeError(`Param ${varName} cannot be negative`);
          }
        },
        // Checks if a variable is a string or not
        //  @param  {any}    variable The variable to be checked
        //  @param  {string} varName  The name of the variable to be checked
        //  @throws {TypeError} If variable is not a string
        checkString(variable, varName) {
          if (typeof variable !== "string") {
            throw new TypeError(`Param ${varName} must be a string`);
          }
        }
      };
    }
  });

  // app/javascript/src/async_notifier.js
  var require_async_notifier = __commonJS({
    "app/javascript/src/async_notifier.js"(exports, module) {
      var TypeChecker = require_type_checker();
      module.exports = class Notifier {
        //  @param {object} notificationsElement The notification DOM element as a jQuery object
        constructor(notificationsElement) {
          TypeChecker.checkNonEmptyJQueryObject(notificationsElement, "notificationsElement");
          this.loadingToast = notificationsElement.find("#async-waiting-indicator");
          this.notificationsElement = notificationsElement;
          this.savedToast = notificationsElement.find("#async-success-indicator");
          this.savedToastTimeouts = [];
          this.waitingSaveOperationCount = 0;
        }
        // Adds notification messages to the notification element
        //  @param  {string} message The message to be displayed
        //  @param  {string} level One of the following logging levels
        //    "error"  Shows a red notification
        //    "info"   Shows a green notification
        //    "warn"   Shows an orange notification
        //  @throws {TypeError}  for a parameter of the incorrect type
        //  @throws {RangeError} for unsupported logging levels
        notify(message, level) {
          TypeChecker.checkString(message, "message");
          const escapedMessage = message.replace(/&/g, "&amp;").replace(/>/g, "&gt;").replace(/</g, "&lt;").replace(/"/g, "&quot;").replace(/'/g, "&apos;");
          switch (level) {
            case "error":
              this.notificationsElement.append(`
          <div class="async-failure-indicator">
            Error: ${escapedMessage}
            <button class="btn btn-danger btn-sm">\xD7</button>
          </div>`).find(".async-failure-indicator button").click(function() {
                $(this).parent().remove();
              });
              break;
            case "info":
              this.notificationsElement.append(`
          <div class="async-success-indicator">
            ${escapedMessage}
            <button class="btn btn-success btn-sm">\xD7</button>
          </div>`).find(".async-success-indicator button").click(function() {
                $(this).parent().remove();
              });
              break;
            case "warn":
              this.notificationsElement.append(`
          <div class="async-warn-indicator">
            ${escapedMessage}
            <button class="btn btn-warning btn-sm">\xD7</button>
          </div>`).find(".async-warn-indicator button").click(function() {
                $(this).parent().remove();
              });
              break;
            default:
              throw new RangeError("Unsupported option for param level");
          }
        }
        // Shows the loading toast
        startAsyncOperation() {
          this.loadingToast.show();
          this.waitingSaveOperationCount++;
        }
        // Shows the saved toast for 2 seconds
        //  @param  {string=}  error The error to be displayed(optional)
        //  @throws {Error}    for trying to resolve more async operations than the amount currently awaiting
        stopAsyncOperation(errorMsg) {
          if (this.waitingSaveOperationCount < 1) {
            const resolveNonexistantOperationError = "Attempted to resolve an async operation when awaiting none";
            this.notify(resolveNonexistantOperationError, "error");
            throw new Error(resolveNonexistantOperationError);
          }
          this.waitingSaveOperationCount--;
          if (this.waitingSaveOperationCount === 0) {
            this.loadingToast.hide();
          }
          if (!errorMsg) {
            this.savedToast.show();
            this.savedToastTimeouts.forEach((timeoutID) => {
              clearTimeout(timeoutID);
            });
            this.savedToastTimeouts.push(setTimeout(() => {
              this.savedToast.hide();
              this.savedToastTimeouts.shift();
            }, 2e3));
          } else {
            if (!(typeof errorMsg === "string" || errorMsg instanceof String)) {
              throw new TypeError("Param errorMsg must be a string");
            }
            this.notify(errorMsg, "error");
          }
        }
      };
    }
  });

  // app/javascript/src/all_casa_admin/patch_notes.js
  var require_patch_notes = __commonJS({
    "app/javascript/src/all_casa_admin/patch_notes.js"() {
      var AsyncNotifier = require_async_notifier();
      var TypeChecker = require_type_checker();
      var patchNotePath = window.location.pathname;
      var patchNoteFormBeforeEditData = {};
      var patchNoteFunctions = {};
      var pageNotifier;
      jQuery.ajaxSetup({
        beforeSend: function() {
          pageNotifier.startAsyncOperation();
        }
      });
      patchNoteFunctions.addPatchNoteUI = function(patchNoteGroupId, patchNoteId, patchNoteList, patchNoteText, patchNoteTypeId) {
        TypeChecker.checkPositiveInteger(patchNoteGroupId, "patchNoteGroupId");
        TypeChecker.checkPositiveInteger(patchNoteId, "patchNoteId");
        TypeChecker.checkPositiveInteger(patchNoteTypeId, "patchNoteTypeId");
        TypeChecker.checkNonEmptyJQueryObject(patchNoteList, "patchNoteList");
        TypeChecker.checkString(patchNoteText, "patchNoteText");
        const newPatchNoteForm = patchNoteList.children().eq(1);
        if (!newPatchNoteForm.length) {
          throw new ReferenceError("Could not find new patch note form");
        }
        const newPatchNoteUI = newPatchNoteForm.clone();
        const newPatchNoteUIFormInputs = patchNoteFunctions.getPatchNoteFormInputs(newPatchNoteUI.children());
        newPatchNoteUI.addClass("new");
        newPatchNoteUI.children().attr("id", `patch-note-${patchNoteId}`);
        newPatchNoteUIFormInputs.noteTextArea.val(patchNoteText);
        newPatchNoteUIFormInputs.dropdownGroup.children().removeAttr("selected");
        newPatchNoteUIFormInputs.dropdownGroup.children(`option[value="${patchNoteGroupId}"]`).attr("selected", true);
        newPatchNoteUIFormInputs.dropdownType.children().removeAttr("selected");
        newPatchNoteUIFormInputs.dropdownType.children(`option[value="${patchNoteTypeId}"]`).attr("selected", true);
        newPatchNoteUIFormInputs.buttonControls.parent().html(`
    <button type="button" class="main-btn primary-btn btn-hovert button-edit">
      <i class="lni lni-pencil-alt mr-10"></i>Edit
    </button>
    <button type="button" class="main-btn danger-btn btn-hover button-delete">
      <i class="lni lni-trash-can mr-10"></i>Delete
    </button>
  `);
        newPatchNoteForm.after(newPatchNoteUI);
        patchNoteFunctions.initPatchNoteForm(newPatchNoteUI);
      };
      patchNoteFunctions.createPatchNote = function(patchNoteGroupId, patchNoteText, patchNoteTypeId) {
        TypeChecker.checkPositiveInteger(patchNoteGroupId, "patchNoteGroupId");
        TypeChecker.checkPositiveInteger(patchNoteTypeId, "patchNoteTypeId");
        TypeChecker.checkString(patchNoteText, "patchNoteText");
        return $.post(patchNotePath, {
          note: patchNoteText,
          patch_note_group_id: patchNoteGroupId,
          patch_note_type_id: patchNoteTypeId
        }).then(function(response, textStatus, jqXHR) {
          if (response.errors) {
            return $.Deferred().reject(jqXHR, textStatus, response.error);
          } else if (response.status && response.status === "created") {
            patchNoteFunctions.resolveAsyncOperation();
          } else {
            patchNoteFunctions.resolveAsyncOperation("Unknown response");
          }
          return response;
        }).fail(function(jqXHR, textStatus, error) {
          patchNoteFunctions.resolveAsyncOperation(error);
        });
      };
      patchNoteFunctions.deletePatchNote = function(patchNoteId) {
        TypeChecker.checkPositiveInteger(patchNoteId, "patchNoteId");
        return $.ajax({
          url: `${patchNotePath}/${patchNoteId}`,
          type: "DELETE"
        }).then(function(response, textStatus, jqXHR) {
          if (response.errors) {
            return $.Deferred().reject(jqXHR, textStatus, response.error);
          } else if (response.status && response.status === "ok") {
            patchNoteFunctions.resolveAsyncOperation();
          } else {
            patchNoteFunctions.resolveAsyncOperation("Unknown response");
          }
          return response;
        }).fail(function(jqXHR, textStatus, error) {
          patchNoteFunctions.resolveAsyncOperation(error);
        });
      };
      patchNoteFunctions.disablePatchNoteForm = function(patchNoteFormInputs) {
        for (const formInput of Object.values(patchNoteFormInputs)) {
          formInput.prop("disabled", true);
        }
      };
      patchNoteFunctions.enablePatchNoteForm = function(patchNoteFormInputs) {
        for (const formInput of Object.values(patchNoteFormInputs)) {
          formInput.removeAttr("disabled");
        }
      };
      patchNoteFunctions.enablePatchNoteFormEditMode = function(patchNoteFormInputs) {
        TypeChecker.checkObject(patchNoteFormInputs, "patchNoteFormInputs");
        patchNoteFunctions.enablePatchNoteForm(patchNoteFormInputs);
        patchNoteFormInputs.buttonControls.off();
        const buttonLeft = patchNoteFormInputs.buttonControls.siblings(".button-edit");
        const buttonRight = patchNoteFormInputs.buttonControls.siblings(".button-delete");
        buttonLeft.html('<i class="fas fa-save"></i> Save');
        buttonLeft.removeClass("button-edit");
        buttonLeft.addClass("button-save");
        buttonRight.html('<i class="fa-solid fa-xmark"></i> Cancel');
        buttonRight.removeClass("button-delete");
        buttonRight.removeClass("btn-danger");
        buttonRight.addClass("button-cancel");
        buttonRight.addClass("btn-secondary");
        patchNoteFunctions.initPatchNoteForm(patchNoteFormInputs.noteTextArea.parent());
      };
      patchNoteFunctions.exitPatchNoteFormEditMode = function(patchNoteFormInputs) {
        TypeChecker.checkObject(patchNoteFormInputs, "patchNoteFormInputs");
        patchNoteFormInputs.noteTextArea.prop("disabled", true);
        patchNoteFormInputs.dropdownGroup.prop("disabled", true);
        patchNoteFormInputs.dropdownType.prop("disabled", true);
        patchNoteFormInputs.buttonControls.off();
        const buttonLeft = patchNoteFormInputs.buttonControls.siblings(".button-save");
        const buttonRight = patchNoteFormInputs.buttonControls.siblings(".button-cancel");
        buttonLeft.html('<i class="fa-solid fa-pen-to-square"></i> Edit');
        buttonLeft.removeClass("button-save");
        buttonLeft.addClass("button-edit");
        buttonRight.html('<i class="fa-solid fa-trash-can"></i> Delete');
        buttonRight.removeClass("btn-secondary");
        buttonRight.removeClass("button-cancel");
        buttonRight.addClass("btn-danger");
        buttonRight.addClass("button-delete");
        patchNoteFunctions.initPatchNoteForm(patchNoteFormInputs.noteTextArea.parent());
      };
      patchNoteFunctions.getPatchNoteFormInputs = function(patchNoteElement) {
        TypeChecker.checkNonEmptyJQueryObject(patchNoteElement, "patchNoteElement");
        const selects = patchNoteElement.children(".label-and-select").children("select");
        const fields = {
          dropdownGroup: selects.eq(1),
          dropdownType: selects.eq(0),
          noteTextArea: patchNoteElement.children("textarea"),
          buttonControls: patchNoteElement.children(".patch-note-button-controls").children("button")
        };
        for (const fieldName of Object.keys(fields)) {
          const field = fields[fieldName];
          if (!(field instanceof jQuery && field.length)) {
            throw new ReferenceError(`Could not find form element ${fieldName}`);
          }
        }
        return fields;
      };
      patchNoteFunctions.getPatchNoteId = function(patchNoteForm) {
        TypeChecker.checkNonEmptyJQueryObject(patchNoteForm, "patchNoteForm");
        return Number.parseInt(patchNoteForm.attr("id").match(/patch-note-(\d+)/)[1]);
      };
      patchNoteFunctions.initPatchNoteForm = function(patchNoteForm) {
        TypeChecker.checkNonEmptyJQueryObject(patchNoteForm, "patchNoteForm");
        patchNoteForm.find(".button-cancel").click(patchNoteFunctions.onCancelEdit);
        patchNoteForm.find(".button-delete").click(patchNoteFunctions.onDeletePatchNote);
        patchNoteForm.find(".button-edit").click(patchNoteFunctions.onEditPatchNote);
        patchNoteForm.find(".button-save").click(patchNoteFunctions.onSavePatchNote);
      };
      patchNoteFunctions.onCancelEdit = function() {
        const patchNoteFormContainer = $(this).parent().parent();
        const formInputs = patchNoteFunctions.getPatchNoteFormInputs(patchNoteFormContainer);
        patchNoteFunctions.patchNoteFormDataResetBeforeEdit(formInputs);
        patchNoteFunctions.exitPatchNoteFormEditMode(formInputs);
      };
      patchNoteFunctions.onCreate = function() {
        try {
          const patchNoteList = $("#patch-note-list");
          const newPatchNoteFormInputs = patchNoteFunctions.getPatchNoteFormInputs($("#new-patch-note"));
          if (!newPatchNoteFormInputs.noteTextArea.val()) {
            pageNotifier.notify("Cannot save an empty patch note", "warn");
            return;
          }
          patchNoteFunctions.disablePatchNoteForm(newPatchNoteFormInputs);
          const patchNoteGroupId = Number.parseInt(newPatchNoteFormInputs.dropdownGroup.val());
          const patchNoteTypeId = Number.parseInt(newPatchNoteFormInputs.dropdownType.val());
          const patchNoteText = newPatchNoteFormInputs.noteTextArea.val();
          patchNoteFunctions.createPatchNote(
            patchNoteGroupId,
            patchNoteText,
            patchNoteTypeId
          ).then(function(response) {
            newPatchNoteFormInputs.noteTextArea.val("");
            patchNoteFunctions.addPatchNoteUI(patchNoteGroupId, response.id, patchNoteList, patchNoteText, patchNoteTypeId);
          }).fail(function(err) {
            pageNotifier.notify("Failed to update UI", "error");
            pageNotifier.notify(err.message, "error");
            console.error(err);
          }).always(function() {
            patchNoteFunctions.enablePatchNoteForm(newPatchNoteFormInputs);
          });
        } catch (err) {
          pageNotifier.notify("Failed to save patch note", "error");
          pageNotifier.notify(err.message, "error");
          console.error(err);
        }
      };
      patchNoteFunctions.onDeletePatchNote = function() {
        const deleteButton = $(this);
        const patchNoteFormContainer = deleteButton.parent().parent();
        const formInputs = patchNoteFunctions.getPatchNoteFormInputs(patchNoteFormContainer);
        switch (deleteButton.text().trim()) {
          case "Delete":
            pageNotifier.notify("Click 2 more times to delete", "warn");
            deleteButton.text("2");
            break;
          case "2":
            deleteButton.text("1");
            break;
          case "1":
            patchNoteFunctions.disablePatchNoteForm(formInputs);
            patchNoteFunctions.deletePatchNote(
              patchNoteFunctions.getPatchNoteId(patchNoteFormContainer)
            ).then(function() {
              patchNoteFormContainer.parent().remove();
            }).fail(function() {
              patchNoteFunctions.enablePatchNoteForm(formInputs);
              deleteButton.html('<i class="fa-solid fa-trash-can"></i> Delete');
            });
            break;
        }
      };
      patchNoteFunctions.onEditPatchNote = function() {
        const patchNoteFormInputs = patchNoteFunctions.getPatchNoteFormInputs($(this).parent().parent());
        patchNoteFunctions.patchNoteFormDataSaveTemp(patchNoteFormInputs);
        patchNoteFunctions.enablePatchNoteFormEditMode(patchNoteFormInputs);
      };
      patchNoteFunctions.onSavePatchNote = function() {
        const patchNoteForm = $(this).parents(".card-body");
        const patchNoteFormInputs = patchNoteFunctions.getPatchNoteFormInputs(patchNoteForm);
        if ($(this).parent().siblings("textarea").val() === "") {
          pageNotifier.notify("Cannot save a blank patch note", "warn");
          return;
        }
        const patchNoteGroupId = Number.parseInt(patchNoteFormInputs.dropdownGroup.val());
        const patchNoteId = patchNoteFunctions.getPatchNoteId(patchNoteForm);
        const patchNoteTypeId = Number.parseInt(patchNoteFormInputs.dropdownType.val());
        const patchNoteText = patchNoteFormInputs.noteTextArea.val();
        patchNoteFunctions.disablePatchNoteForm(patchNoteFormInputs);
        patchNoteFunctions.savePatchNote(
          patchNoteGroupId,
          patchNoteId,
          patchNoteText,
          patchNoteTypeId
        ).then(function(response) {
          patchNoteFormInputs.noteTextArea.prop("disabled", true);
          patchNoteFormInputs.dropdownGroup.prop("disabled", true);
          patchNoteFormInputs.dropdownType.prop("disabled", true);
          patchNoteFormInputs.buttonControls.off();
          const buttonLeft = patchNoteFormInputs.buttonControls.siblings(".button-save");
          const buttonRight = patchNoteFormInputs.buttonControls.siblings(".button-cancel");
          buttonLeft.html('<i class="fa-solid fa-pen-to-square"></i> Edit');
          buttonLeft.removeClass("button-save");
          buttonLeft.addClass("button-edit");
          buttonRight.html('<i class="fa-solid fa-trash-can"></i> Delete');
          buttonRight.removeClass("btn-secondary");
          buttonRight.removeClass("button-cancel");
          buttonRight.addClass("btn-danger");
          buttonRight.addClass("button-delete");
          patchNoteFunctions.initPatchNoteForm(patchNoteFormInputs.noteTextArea.parent());
        }).fail(function(err) {
          pageNotifier.notify("Failed to update patch note", "error");
          pageNotifier.notify(err.message, "error");
          console.error(err);
          patchNoteFunctions.enablePatchNoteForm(patchNoteFormInputs);
        }).always(function() {
          patchNoteFormInputs.buttonControls.prop("disabled", false);
        });
      };
      patchNoteFunctions.patchNoteFormDataResetBeforeEdit = function(patchNoteFormInputs) {
        TypeChecker.checkObject(patchNoteFormInputs, "patchNoteFormInputs");
        let patchNoteDataBeforeEditing;
        try {
          patchNoteDataBeforeEditing = patchNoteFormBeforeEditData[patchNoteFunctions.getPatchNoteId(patchNoteFormInputs.noteTextArea.parent())];
          patchNoteFormInputs.noteTextArea.val(patchNoteDataBeforeEditing.note);
          patchNoteFormInputs.dropdownGroup.val(patchNoteDataBeforeEditing.groupId);
          patchNoteFormInputs.dropdownType.val(patchNoteDataBeforeEditing.typeId);
        } catch (e) {
          pageNotifier.notify("Failed to load patch note data from before editing", "error");
          throw e;
        }
      };
      patchNoteFunctions.patchNoteFormDataSaveTemp = function(patchNoteFormInputs) {
        TypeChecker.checkObject(patchNoteFormInputs, "patchNoteFormInputs");
        try {
          patchNoteFormBeforeEditData[patchNoteFunctions.getPatchNoteId(patchNoteFormInputs.noteTextArea.parent())] = {
            note: patchNoteFormInputs.noteTextArea.val(),
            groupId: Number.parseInt(patchNoteFormInputs.dropdownGroup.val()),
            typeId: Number.parseInt(patchNoteFormInputs.dropdownType.val())
          };
        } catch (e) {
          pageNotifier.notify("Failed to save patch note form data before editing", "error");
          throw e;
        }
      };
      patchNoteFunctions.resolveAsyncOperation = function(error) {
        if (error instanceof Error) {
          error = error.message;
        }
        pageNotifier.stopAsyncOperation(error);
      };
      patchNoteFunctions.savePatchNote = function(patchNoteGroupId, patchNoteId, patchNoteText, patchNoteTypeId) {
        TypeChecker.checkPositiveInteger(patchNoteGroupId, "patchNoteGroupId");
        TypeChecker.checkPositiveInteger(patchNoteId, "patchNoteGroupId");
        TypeChecker.checkPositiveInteger(patchNoteTypeId, "patchNoteTypeId");
        TypeChecker.checkString(patchNoteText, "patchNoteText");
        return $.ajax({
          url: `${patchNotePath}/${patchNoteId}`,
          type: "PUT",
          data: {
            note: patchNoteText,
            patch_note_group_id: patchNoteGroupId,
            patch_note_type_id: patchNoteTypeId
          }
        }).then(function(response, textStatus, jqXHR) {
          if (response.errors) {
            return $.Deferred().reject(jqXHR, textStatus, response.error);
          } else if (response.status && response.status === "ok") {
            patchNoteFunctions.resolveAsyncOperation();
          } else {
            patchNoteFunctions.resolveAsyncOperation("Unknown response");
            console.error("Unexpected repsonse");
            console.error(response);
          }
          return response;
        }).fail(function(jqXHR, textStatus, error) {
          patchNoteFunctions.resolveAsyncOperation(error);
        });
      };
      $("document").ready(() => {
        if (!window.location.pathname.includes("patch_notes")) {
          return;
        }
        try {
          const asyncNotificationsElement = $("#async-notifications");
          pageNotifier = new AsyncNotifier(asyncNotificationsElement);
          $("#new-patch-note button").click(patchNoteFunctions.onCreate);
          $("#patch-note-list .button-delete").click(patchNoteFunctions.onDeletePatchNote);
          $("#patch-note-list .button-edit").click(patchNoteFunctions.onEditPatchNote);
        } catch (err) {
          pageNotifier.notify("Could not intialize app", "error");
          pageNotifier.notify(err.message, "error");
          console.error(err);
        }
      });
    }
  });

  // app/javascript/all_casa_admin.js
  require_tables();
  require_patch_notes();
})();
