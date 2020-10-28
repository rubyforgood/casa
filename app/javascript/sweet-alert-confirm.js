import Swal from 'sweetalert2';
import Rails from '@rails/ujs';

window.Swal = Swal;

// Behavior after click to confirm button
const confirmed = (element, result) => {
    // If result `success`
    if(result.value) {
        let reloadAfterSuccess = !!element.getAttribute('data-reload');
        // Removing attribute for unbinding JS event.
        element.removeAttribute('data-confirm-swal');
        // Following a destination link
        element.click();
        // window.location.reload();
        Swal.fire('Success!', result.message || '', 'success')
            .then((_result) => {
                if (reloadAfterSuccess) {
                    window.location.reload();
                }
            });
    
    }
};


// Display the confirmation dialog
const showConfirmationDialog = (element) => {
    const message = element.getAttribute('data-confirm-swal');
    const text    = element.getAttribute('data-text');
    const on_success  = element.getAttribute('data-on-success');
    const on_fail = element.getAttribute('data-on-fail')

    Swal.fire({
          title:             message || 'Are you sure?',
          text:              text || '',
          icon:              'warning',
          showCancelButton:  true,
        confirmButtonText: on_success || 'Ok',
        cancelButtonText:  on_fail || 'No',
    }).then(result => confirmed(element, result));
}

const allowAction = (element) => {
    if (element.getAttribute('data-confirm-swal') === null) {
        return true;
    }

    showConfirmationDialog(element);
    return false;
};

function handleConfirm(element) {
    if (!allowAction(this)) {
        Rails.stopEverything(element);
    }
}

Rails.delegate(document, 'a[data-confirm-swal]', 'click', handleConfirm);