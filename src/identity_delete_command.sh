
name="${args['name']}"

hush.fail_device_unmounted

# If the user wants to delete in the backup, check that a medium is mounted, and fail if not. 
if [[ ${args['--backup']} -eq 1 ]] && ! ls -1 /dev/mapper/"${BACKUP_MAPPER}" &> /dev/null; then
    _failure "User specified to also delete on backup, but none is mounted. \
        Mount one with 'risks backup mount <dev> and rerun this command"
fi

# Set the identity variables needed by all functions in this script run,
# but close the identity itself. We set the resource to delete for this command. 
identity.set "${args['name']}"

if identity.active && [[ "$(cat "${RISKS_IDENTITY_FILE}")" == "$name" ]]; then
    args["resource"]="identity"
    args["identity"]="$name"
    risks_close_command
fi

_info "Starting deletion of identity '$name'"
_info "Some of the wiping operations will take some time (several minutes). Please wait."

#  Delete the identity graveyard directory, and the associated fscrypt policy
_info "Wiping graveyard ($(graveyard.identity_directory "$IDENTITY"))"
graveyard.delete

# Delete the coffin files in the graveyard, and coffin key in hush
_info "Wiping GPG coffin"
_run risks_hush_rw_command
gpg.delete_coffin
_run risks_hush_ro_command

# Delete the identity graveyard backup.
if [[ "${args['--backup']}" -eq 1 ]]; then
    backup.delete_identity
fi

_info "Deleted identity $name"
