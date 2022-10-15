name="${args[tomb_name]}"

# We need the hush device, on which to save the key
if ! is_luks_mapper_present "${SDCARD_ENC_PART_MAPPER}" ; then
    _failure "Hush device not mounted. Need access to delete tomb key in it."
fi

_set_identity "${args[identity]}"

# Set the hush device with read-write permissions, 
# since we must delete the tomb key file on it.
_run risks_hush_rw_command

# This call handles everything, including confirmation
# when sensitive tombs are to be deleted.
delete_tomb "$name"

# And reset the hush
_run risks_hush_ro_command

# Delete in backup if specified
if [[ "${args[--backup]}" -eq 1 ]]; then
    _message "Deleting tomb backup"
    delete_tomb_backup "$name"
fi

_message "Deleted tomb $name"
