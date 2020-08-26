function handleBulkUserCheckBoxClick(target, opp, id, isDiscarded) {
  const pairedCheckBox = document.getElementById(`${opp}_user_ids_${id}`);

  if (target.checked) {
    pairedCheckBox.disabled = true;
  } else if (isDiscarded) {
    pairedCheckBox.disabled = false;
  }
}

let hasClickedDestroyCheckBox = false;

function handleDestroyCheckBoxClickFor(id, evt, isDiscarded) {
  let proceed = true;

  if (isDiscarded &&
      !hasClickedDestroyCheckBox) {
    hasClickedDestroyCheckBox = true;

    proceed = confirm("This user is already discarded. If you submit the form with this box checked, the user will be permanently deleted.");
  }

  if (!proceed) {
    evt.preventDefault();
  }

  if (isDiscarded) {
    const o = document.getElementById(`restore_user_ids_${id}`) || {};

    o.disabled = !o.disabled;
  }
}

function handleRestoreCheckBoxClickFor(id) {
  const o = document.getElementById(`destroy_user_ids_${id}`) || {};

  o.disabled = !o.disabled;
}
