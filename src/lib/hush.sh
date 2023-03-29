
# hush.format_partitions is a separate function because we must
# avoid bashly CLI framework to indent the Heredoc in there.
# $1 - Path to hush full sd_drive, e.g /dev/xvdi
# $2 - Start of the encrypted partition, in number of sectors.
function hush.format_partitions ()
{
    local sd_drive="$1"
    local start_enc_sectors="$2"

    nl=$'\n' # Needed because EOF does not preserve some newlines.
    _run sudo fdisk -u "${sd_drive}" <<EOF
n
p
1

+${start_enc_sectors}
n
p
2

$nl
w

EOF
}

# hush.fail_device_unmounted exits the program if the hush device is not mounted.
function hush.fail_device_unmounted ()
{
    if ! device.hush_is_mounted ; then
        _failure "The hush device is not mounted. Mount it first and rerun the command."
    fi
}

# hush.write_risks_scripts copies the various vault risks scripts in a special directory in the
# hush partition, along with a small installation scriptlet, so that upon mounting the hush
# somewhere else, the user can quickly install and use the risks on the new machine.
function hush.write_risks_scripts ()
{
    local udev_rules="$1"

    _info "Copying risks scripts onto the hush partition"

    # Scripts/program
    mkdir -p "$RISKS_SCRIPTS_INSTALL_PATH"
    sudo cp "$(which risks)" "$RISKS_SCRIPTS_INSTALL_PATH"
    sudo chmod go-rwx "$RISKS_SCRIPTS_INSTALL_PATH"
    sudo cp /usr/local/share/zsh/site-functions/_risks "$RISKS_SCRIPTS_INSTALL_PATH"

    cat >"${RISKS_SCRIPTS_INSTALL_PATH}/install" <<'EOF'
#!/usr/bin/env zsh

declare INSTALL_SCRIPT_DIR="${0:a:h}"
declare INSTALL_SCRIPT_PATH="$0"
declare BINARY_INSTALL_DIR="${HOME}/.local/bin"
declare COMPLETIONS_INSTALL_DIR="${HOME}/.local/share/zsh/site-functions"

## Binary
#
echo "Installing risks script in ${BINARY_INSTALL_DIR}"
if [[ ! -d "${BINARY_INSTALL_DIR}" ]]; then
    mkdir -p "${BINARY_INSTALL_DIR}"
fi
cp "${INSTALL_SCRIPT_PATH}" "${BINARY_INSTALL_DIR}"
sudo chmod go-rwx "${INSTALL_SCRIPT_PATH}"
sudo chmod u+x "${INSTALL_SCRIPT_PATH}"

## Completions
#
echo "Installing risks completions in ${COMPLETIONS_INSTALL_DIR}"
if [[ ! -d "${COMPLETIONS_INSTALL_DIR}" ]]; then
    echo "Completions directory does not exist. Creating it."
    echo "You should add it to ${FPATH} and reload your shell"
    mkdir -p "${COMPLETIONS_INSTALL_DIR}"
fi
cp "${INSTALL_SCRIPT_DIR}/_risks" "${COMPLETIONS_INSTALL_DIR}"

echo "Done installing risks scripts."
EOF

    # Hush device udev rules: UUID is evaluated at format time here,
    # then installed onto the hush, so value freezed once and for all.
    cat >"${RISKS_SCRIPTS_INSTALL_PATH}/install_udev_rules" <<EOF
#!/bin/sh

# Maps this device ID to be automatically mounted as /dev/hush mapper.
${udev_rules}
EOF

    sudo chmod go-rwx "$RISKS_SCRIPTS_INSTALL_PATH/install_udev_rules"
}
