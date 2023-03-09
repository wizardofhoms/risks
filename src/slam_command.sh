
# First set the identity variables with the active one.
identity.set ""

_warning "risks" "Slaming identity $IDENTITY"

_info "Slaming PASS tomb ..."
_run tomb.slam "$PASS_TOMB_LABEL"

_info "Slaming SSH tomb ..."
_run tomb.slam "$SSH_TOMB_LABEL"

_info "Slaming Management tomb ..."
_run tomb.slam "$MGMT_TOMB_LABEL"

_info "Closing GPG coffin ..."
gpg.close_coffin
# done

# Finally, find all other tombs...
tombs=$(tomb list 2>&1 \
    | sed -n '0~4p' \
    | awk -F" " '{print $(3)}' \
    | rev | cut -c2- | rev | cut -c2-)

# ... and close them
while read -r tomb_name ; do
    if [[ -z $tomb_name ]]; then
        continue
    fi

    _info "Slaming tomb $tomb_name ..."
    _run tomb slam "$tomb_name"
done <<< "$tombs"

# Close graveyard backup if open
if device.luks_mapper_found "$BACKUP_MAPPER" ; then
    risks_backup_lock_command
fi

# 3 - Unmount hush and backup
echo
_info "Unmounting hush partition"
_run risks_hush_umount_command
_catch "Failed to unmount hush partition"

_info "Umounting backup device"
_run risks_backup_umount_command
_catch "Failed to umount backup device"
