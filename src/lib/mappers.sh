# device.named_mapper_found checks if the "hush partition"
# has been seen by kernel and returns 0 if true.
function device.named_mapper_found ()
{
    ls -1 "/dev/${1}" &> /dev/null
}

# device.luks_mapper_found checks if the "hush partition"
# has been already decrypted and returns 0 if true.
function device.luks_mapper_found ()
{
    ls -1 "/dev/mapper/${1}" &> /dev/null
}

# device.luks_is_opened checks if a luks mapper given
# as argument is opened/unlocked, and returns 0 if true.
# $1 - LUKS device mapper name.
function device.luks_is_opened ()
{
    ls "/dev/mapper/${1}" &> /dev/null
}

# device.luks_is_mounted checks if a luks mapper given
# as argument is mounted, and returns 0 if true.
# $1 - LUKS device mapper name.
function device.luks_is_mounted ()
{
    mount | grep "^${1}" &> /dev/null
}

# device.hush_is_mounted checks if the "hush partition"
# is already mounted and returns 0 if true.
function device.hush_is_mounted ()
{
    mount | grep "^/dev/mapper/${SDCARD_ENC_PART_MAPPER}" &> /dev/null
}

# device.hush_is_rw returns 0 if the hush device mapper
# mount directory has read-write permissions, 1 if not.
function device.hush_is_rw ()
{
    mount | grep "hush" | grep "(rw,relatime)" &> /dev/null
}

# device.is_encrypted_block checks if a *block* device is encrypted.
# Returns 0 if it is an encrypted block device, or 1 if not or failure.
# $1 - /path/to/block/device
function device.is_encrypted_block ()
{
    local	 b=$1 # Path to a block device
    local	 s="" # lsblk option -s (if available)

    # Issue #163
    # lsblk --inverse appeared in util-linux 2.22
    # but --version is not consistent...
    lsblk --help | grep -Fq -- --inverse
    [[ $? -eq 0 ]] && s="--inverse"

    sudo lsblk $s -o type -n "$b" 2>/dev/null \
        | grep -e -q '^crypt$'

    return $?
}

# device.link_hush_udev_rules checks that the udev-rules file that risks
# keeps in its config directory is linked against a file in /etc/udev/rules.d/,
# and if not, echoes this link to the /rw/config/rc.local file.
function device.link_hush_udev_rules ()
{
    # We don't do anything if we don't have a udev-rules file in
    # the risks directory yet.
    if [[ ! -e "$UDEV_RULES_PATH" ]]; then
        return
    fi

    # Or check that a symlink exists, not taking into account
    # the number in the name. If not found:
    if ! ls /etc/udev/rules.d/*"${UDEV_RULES_FILE}" &> /dev/null ; then
        _info "No link to hush udev rules detected, setting it persistent and for this session"

        # - echo the link command into rc.local
        _verbose "Adding the link command to /rw/config/rc.local"
        sudo sh -c 'echo "# The following line was added by the risks CLI, to map hush devices when plugged in this VM" >> /rw/config/rc.local'
        sudo sh -c 'echo "ln -s '"$UDEV_RULES_PATH"' /etc/udev/rules.d/99-risks-hush.rules" >> /rw/config/rc.local'

        # - Create the symlink for this session
        _verbose "Linking the file for this login session"
        sudo ln -s "$UDEV_RULES_PATH" /etc/udev/rules.d/99-risks-hush.rules

        # - reload the udev rules
        _verbose "Reloading udev rules"
        sudo udevadm control --reload-rules
    fi
}

# device.unmount attempts to unmount a directory from the system.
# $1 - A name to match with grep when searching mount points.
#      When a line is matched, the corresponding mount path is used.
#      Ex: ramdisk on /home/user/.gnupg, where ramdisk is $1, and
#      ~/.gnupg is the path that this command will attempt to umount.
function device.unmount ()
{
    local name="${1}"
    local exclude=(grep -v -e /rw) # Mount paths we don't want to touch.

    while read -r match; do
        # Ensure the 2nd word is 'on', which means the third is the path.
        [[ -z "${match}" ]] && continue
        [[ "$(echo "$match" | awk '{print $2}')" == 'on' ]] || continue

        # Or attempt to unmount.
        local mount_point
        mount_point="$(echo "$match" | awk '{print $3}')"
        [[ -z "${mount_point}" ]] && continue

        sudo umount -l "${mount_point}" &>/dev/null || _warning "Failed to unmount $mount_point"

    done < <(mount | grep "${name}" | "${exclude[@]}" 2>/dev/null)
}
