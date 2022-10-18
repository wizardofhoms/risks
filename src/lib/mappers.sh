# Checks if the "hush partition" has been seen by kernel and returns 0 if true
is_named_partition_mapper_present()
{
    ls -1 "/dev/${1}" &> /dev/null
}

# Checks if the "hush partition" has been already decrypted and returns 0 if true
is_luks_mapper_present()
{
    ls -1 "/dev/mapper/${1}" &> /dev/null
}

is_luks_open()
{
    ls "/dev/mapper/${1}" &> /dev/null
}

is_luks_mounted()
{
    mount | grep "^${1}" &> /dev/null
}

# Checks if the "hush partition" is already mounted and returns 0 if true
is_hush_mounted()
{
    mount | grep "^/dev/mapper/${SDCARD_ENC_PART_MAPPER}" &> /dev/null
}

# Returns 0 if yes, 1 if not.
is_hush_read_write ()
{
    mount | grep "hush" | grep "(rw,relatime)" &> /dev/null
}

# Check if a *block* device is encrypted
# Synopsis: _is_encrypted_block /path/to/block/device
# Return 0 if it is an encrypted block device
is_encrypted_block() {
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

# link_hush_udev_rules checks that the udev-rules file that risks
# keeps in its config directory is linked against a file in /etc/udev/rules.d/,
# and if not, echoes this link to the /rw/config/rc.local file.
link_hush_udev_rules () 
{
    # We don't do anything if we don't have a udev-rules file in
    # the risks directory yet.
    if [[ ! -e "$UDEV_RULES_PATH" ]]; then
        return
    fi

    # Or check that a symlink exists, not taking into account 
    # the number in the name. If not found:
    if ! ls /etc/udev/rules.d/*"${UDEV_RULES_FILE}" &> /dev/null ; then
        _message "No link to hush udev rules detected, setting it persistent and for this session"

        # - echo the link command into rc.local
        _verbose "Adding the link command to /rw/config/rc.local"
        sudo sh -c 'echo "# The following line was added by the risks CLI, to map hush devices when plugged in this VM" > /rw/config/rc.local'
        sudo sh -c 'echo "sudo ln -s '"$UDEV_RULES_PATH"' /etc/udev/rules.d/99-risks-hush.rules" > /rw/config/rc.local'

        # - Create the symlink for this session
        _verbose "Linking the file for this login session"
        sudo ln -s "$UDEV_RULES_PATH" /etc/udev/rules.d/99-risks-hush.rules

        # - reload the udev rules
        _verbose "Reloading udev rules"
        sudo udevadm control --reload-rules
    fi
}
