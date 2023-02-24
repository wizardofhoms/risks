
local keygrip keypath

_set_identity "${args['identity']}"

# Backup/hush and identity checks
check_hush_mounted
check_backup_mounted
check_identity_active

# 2 - Set the partition read-write and remove from the gpg keyring
risks_hush_rw_command

# 3 - Copy/check the private key and revoc certificate, check correcly copied, close GPG tomb
keygrip="$(gpg -K | grep Keygrip | head -n 1 | cut -d= -f 2 | sed 's/ //g').key"
_verbose "Keygrip: $keygrip"
keyring_path="${RAMDISK}/private-keys-v1.d/${keygrip}" 

_info "Wiping private GPG key ${keygrip} from keyring"
_run wipe -rf "${keyring_path}" \
    || _warning "Failed to delete master private key from keyring !"

risks_hush_ro_command

_info "Removed private key from keyring"
