
if ! device.named_mapper_found "${SDCARD_ENC_PART_MAPPER}" ; then
    _failure "Device mapper /dev/${SDCARD_ENC_PART_MAPPER} not found.\n\
        Be sure you have attached your hush partition.       "
fi

if device.hush_is_mounted ; then
    _info "Sdcard already mounted"
    play_sound
    return 0
fi

if ! device.luks_mapper_found "${SDCARD_ENC_PART_MAPPER}" ; then
    # decrypts the "hush partition": it will ask for passphrase
    if ! sudo cryptsetup open --type luks "${SDCARD_ENC_PART}" "${SDCARD_ENC_PART_MAPPER}" ; then
        _failure "The hush partition ${SDCARD_ENC_PART} can not be decrypted"
    fi
fi

# creates the "hush partition" mount point if it doesn't exist
if [ ! -d "${HUSH_DIR}" ]; then
    mkdir -p "${HUSH_DIR}" &> /dev/null
fi

# mounts the "hush partition" in read-only mode by default
if ! sudo mount -o ro "/dev/mapper/${SDCARD_ENC_PART_MAPPER}" "${HUSH_DIR}" ; then
    _failure "/dev/mapper/${SDCARD_ENC_PART_MAPPER} can not be mounted on ${HUSH_DIR}"
fi

play_sound "plugged"

echo
_success "SDCARD has been mounted read-only. To give write permissions, use:"
_success "risks hush rw"
echo
