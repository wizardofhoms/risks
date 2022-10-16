
if ! is_named_partition_mapper_present "${SDCARD_ENC_PART_MAPPER}" ; then
    _failure "Device mapper /dev/mapper/${SDCARD_ENC_PART_MAPPER} not found.\n \
        Be sure you have attached your hush partition."
fi

# Check there is a hush device mounted
if is_hush_mounted ; then
    if ! sudo umount -f "${HUSH_DIR}" ; then
        _failure "/dev/mapper/${SDCARD_ENC_PART_MAPPER} can not be umounted from ${HUSH_DIR}"
    fi
fi

# Check that the hush is not mounted with read-write permissions.
# If yes, do not proceed further, as some other process might be
# writing to it.
if is_hush_read_write ; then
    _failure "Hush device is currently mounted with read-write permissions. \
        Please ensure not process is writing to it, and mount it read-only."

# Finally try to umount it and close the LUKS filesystem
if is_luks_mapper_present "${SDCARD_ENC_PART_MAPPER}" ; then
    if ! sudo cryptsetup close "${SDCARD_ENC_PART_MAPPER}" ; then
        _failure "SDCARD can not be closed"
    fi
fi

play_sound "unplugged"

_message "Hush device is unmounted and closed"
