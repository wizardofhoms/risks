# If identity graveyard backup is unlocked, close it
if backup_is_unlocked; then
    risks_backup_lock_command
fi

if [[ -e "$BACKUP_MOUNT_DIR" ]] ; then
    if ! sudo umount -f "${BACKUP_MOUNT_DIR}" ; then
        _failure "/dev/mapper/${BACKUP_MAPPER} can not be unmounted from ${BACKUP_MOUNT_DIR}"
    fi
fi

if is_luks_mapper_present "${BACKUP_MAPPER}" ; then
    if ! sudo cryptsetup close "${BACKUP_MAPPER}" ; then
        _failure "Backup LUKS can not be closed"
    fi
fi

play_sound "unplugged"

_info "Backup device is umounted and closed"
