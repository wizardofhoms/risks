
local name identity expiry pendrive email

## Pre-run parameters setup
name="${args['name']}"
name="$(identity.get_args_name "${name}")"
identity="${name// /_}"
expiry="$(identity.get_args_expiry "${args['expiry_date']}")"
email="$(identity.get_args_mail "${name}" "${args['email']}")"
pendrive="${args['--backup']}" # Backup is optional

# Checks
#
# Ensure no identity and hush is safe to write onto.
if identity.active ; then
    _failure "An identity seems to be active. Cannot safely create a new one."
fi

if ! device.hush_is_mounted; then
    _failure "No hush device is mounted and available to store identity keys."
fi

if [[ -w "$HUSH_DIR" ]]; then
    _failure "Hush is currently mounted read-write. \n \
        Please ensure nothing is writing to it and set it to read-only first"
fi

_in_section 'risks' 6
_info "Starting new identity generation process"
_warning "Do not unplug hush and backup devices during the process"

# Use the identity name to set its file encryption key.
identity.set "$identity"

echo
_info "${fg_bold[white]}Username${reset_color}:       ${name}"
_info "${fg_bold[white]}GPG recipient${reset_color}:  ${email}"
_info "${fg_bold[white]}Subkeys expiry${reset_color}: ${expiry}"
echo


# GPG
#
# Generate GPG keypairs with a different passphrase than the one
# we use for encrypting file/directory names and contents.
# This passphrase is the one returned by the risks gpg pass command.
_in_section 'gpg' && _info "Setting up RAMDisk and GPG backend"
gpg.setup_keyring

_info "Generating GPG keys"
GPG_PASS=$(crypt.passphrase "$GPG_TOMB_LABEL")
echo -n "$GPG_PASS" | xclip -loops 1 -selection clipboard
_warning "GPG passphrase copied to clipboard with one-time use only"
_info -n "Paste it in the coming GPG prompt when creating builtin tombs\n"
_run gpg.generate_keys "$name" "$email" "$expiry"

# Setup the identity graveyard directory with fscrypt protection
_in_section 'coffin' && _info "Creating and setting encrypted identity directory"
graveyard.create

# At this point, we need access to the hush device in read-write mode.
_in_section 'hush' && _info "Mounting hush device with read-write permissions"
risks_hush_mount_command
_run risks_hush_rw_command

# Then only, generate the coffin and copy it into the graveyard root directory.
_in_section 'coffin' && _info "Creating and testing GPG coffin container"
gpg.generate_coffin

# Clean RAM disk, remove private keys from the keyring and test open/close
_in_section 'gpg' && _info "Cleaning and backing keyring privates"
gpg.cleanup_keyring "$email"


## Builtin tombs
#
_in_section 'pass' && _info "Initializing password-store"
tomb.create_password_store "$email"

if [[ "${args['--burner']}" -eq 1 ]]; then
    echo && _success "risks" "Identity (burner) generation complete." && echo
    return
fi

_in_section 'ssh' && _info "Generating SSH keypair and multi-key ssh-agent script"
ssh.setup "$email"

## Create a tomb to use for admin storage:
# config files, etc, and set default key=values
_in_section 'mgmt' && _info "Creating management tomb"
tomb.create_management

risks_hush_ro_command

## Backup
#
if [[ -n "$pendrive" ]]; then
    _in_section 'backup' && _info "Setting identity backup and making initial one"

    risks_backup_mount_command
    _catch "failed to decrypt and mount backup drive"

    # Some setup is needed for this identity to have access to its backup
    _verbose "Setting graveyard backup for this identity"
    _run backup.setup_identity
    _catch "Failed to setup identity backup graveyard"

    # And then actually back it up
    risks_backup_identity_command
    _catch "Failed to correctly backup data"

    # Remove the GPG tomb from the user graveyard.
    risks_backup_unlock_command
    backup.move_gpg_master_key
    risks_backup_lock_command

    risks_backup_umount_command
fi

## ALL DONE
echo && _success "risks" "Identity generation complete." && echo
