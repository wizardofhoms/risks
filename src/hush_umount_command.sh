
# No identity should be active
if identity.active; then
    _failure "An identity is active, close it first and rerun the command."
fi

# Nothing to do if no hush mounted.
if ! device.named_mapper_found "${SDCARD_ENC_PART_MAPPER}" ; then
    _failure "Device mapper /dev/mapper/${SDCARD_ENC_PART_MAPPER} not found.\n \
        Be sure you have attached your hush partition."
fi

# Check there is a hush device mounted
if device.hush_is_mounted ; then
    if device.hush_is_rw ; then
        _failure "Hush device is currently mounted with read-write permissions. \
            Please ensure not process is writing to it, and mount it read-only."
    fi

    if ! sudo umount -f "${HUSH_DIR}" ; then
        _failure "/dev/mapper/${SDCARD_ENC_PART_MAPPER} can not be umounted from ${HUSH_DIR}"
    fi
fi

# Finally try to umount it and close the LUKS filesystem
if device.luks_mapper_found "${SDCARD_ENC_PART_MAPPER}" ; then
    if ! sudo cryptsetup close "${SDCARD_ENC_PART_MAPPER}" ; then
        _failure "SDCARD can not be closed"
    fi
fi

play_sound "unplugged"

_info "Hush device is unmounted and closed"
