
name="${args['tomb_name']}"

check_hush_mounted

# Check the backup medium is here if asked to delete it also.
if [[ "${args['--backup']}" -eq 1 ]]; then
    check_backup_mounted
fi

_set_identity "${args['identity']}"

# Set the hush device with read-write permissions, 
# since we must delete the tomb key file on it.
_run risks_hush_rw_command

# This call handles everything, including confirmation
# when sensitive tombs are to be deleted.
delete_tomb "$name"

# And reset the hush
_run risks_hush_ro_command

# Delete in backup if specified
if [[ "${args['--backup']}" -eq 1 ]]; then
    _info "Deleting tomb backup"
    delete_tomb_backup "$name"
fi

_info "Deleted tomb $name"
