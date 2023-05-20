
identity.set "${args['identity']}"

_info "Closing PASS tomb ..."
_run tomb.slam "$PASS_TOMB_LABEL"

_info "Closing SSH tomb ..."
_run tomb.slam "$SSH_TOMB_LABEL"

_info "Closing Management tomb ..."
_run tomb.slam "$MGMT_TOMB_LABEL"

# Finally, find all other tombs...
_info "Closing all other tombs"
_run tomb slam

# Close graveyard backup if open
if device.luks_mapper_found "$BACKUP_MAPPER" ; then
    risks_backup_lock_command
fi

_info "Closing GPG coffin ..."
gpg.close_coffin
