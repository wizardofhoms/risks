
# First set the identity variables with the active one. 
_set_identity ""

_warning "risks" "Slaming identity $IDENTITY"

_info "Slaming PASS tomb ..."
_run slam_tomb "$PASS_TOMB_LABEL"

_info "Slaming SSH tomb ..."
_run slam_tomb "$SSH_TOMB_LABEL"

_info "Slaming Management tomb ..."
_run slam_tomb "$MGMT_TOMB_LABEL"

_info "Closing GPG coffin ..."
close_coffin
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
if is_luks_mapper_present "$BACKUP_MAPPER" ; then
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
