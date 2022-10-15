name="${args[name]}"

# We need the hush device, on which to save the key
if ! is_luks_mapper_present "${SDCARD_ENC_PART_MAPPER}" ; then
    _failure "Hush device not mounted. Need access to delete keys in it."
fi

# If the user wants to delete in the backup, immediately check
# that a medium is mounted, and fail if not. Normally not finding
# one is not a problem, as the user could rerun the same command
# with the backup mounted: since the first steps (system graveyard
# and coffin) will not throw an irrecoverable error, it will simply
# go through to the backup wipe step.
# Still, fail now so that users don't panic with some data being wiped and some not
if [[ ${args[--backup]} -eq 1 ]] && ! ls -1 /dev/mapper/"${BACKUP_MAPPER}" &> /dev/null; then
    _failure "User specified to also delete on backup, but none is mounted. \
  Mount one with 'risks backup mount <dev> and rerun this command"
fi

# Set the identity variables needed by all functions...
_set_identity "${args[name]}"

# ... but close the identity itself. We set the resource to delete for this command. 
if _identity_active && [[ "$(cat "${RISKS_IDENTITY_FILE}")" == "$name" ]]; then
    args["resource"]="identity"
    args["identity"]="$name"
    risks_close_command
fi

_message "Starting deletion of identity '$name'"
_message "Some of the wiping operations will take some time (several minutes). Please wait."

# 1 - Delete the identity graveyard directory, and the associated fscrypt policy
_message "Wiping graveyard"
delete_graveyard

# 2 - Delete the coffin files in the graveyard, and coffin key in hush
# Set the hush device with read-write permissions, 
# since we must delete the coffin key file on it.
_run risks_hush_rw_command

_message "Wiping GPG coffin"
delete_coffin

# And reset the hush
_run risks_hush_ro_command

# 3 - Delete the identity graveyard backup.
# The function called takes care of mounting/unmounting, etc.
if [[ "${args[--backup]}" -eq 1 ]]; then
    delete_identity_backup
fi

_message "Deleted identity $name"
