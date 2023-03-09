
name="${args['tomb_name']}"

hush.fail_device_unmounted

# Check the backup medium is here if asked to delete it also.
if [[ "${args['--backup']}" -eq 1 ]]; then
    backup.fail_device_unmounted
fi

identity.set "${args['identity']}"

# Set the hush device with read-write permissions, 
# since we must delete the tomb key file on it.
_run risks_hush_rw_command

# This call handles everything, including confirmation
# when sensitive tombs are to be deleted.
tomb.delete "$name"

# And reset the hush
_run risks_hush_ro_command

# Delete in backup if specified
if [[ "${args['--backup']}" -eq 1 ]]; then
    _info "Deleting tomb backup"
    backup.tomb_delete "$name"
fi

_info "Deleted tomb $name"
