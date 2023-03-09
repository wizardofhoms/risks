
# Connected terminal
typeset -H _TTY
GPG_TTY=$(tty)  # Needed for GPG operations
export GPG_TTY

# Remove verbose errors when * don't yield any match in ZSH
setopt +o nomatch

# The generated script makes use of BASH_REMATCH, set compat for ZSH
setopt BASH_REMATCH

# Use colors unless told not to
{ ! option_is_set --no-color } && { autoload -Uz colors && colors }

## Checks ##

# Don't run as root
if [[ $EUID -eq 0 ]]; then
    echo "This script must be run as user"
    exit 2
fi

# Configuration file -------------------------------------------------------------------------------
#
# Directory where risk stores its state
typeset -rg RISKS_DIR="${HOME}/.risks"  

# Create the risk directory if needed
[[ -e $RISKS_DIR ]] || { mkdir -p $RISKS_DIR && _info "Creating RISKS directory in $RISKS_DIR" }

# Write the default configuration if it does not exist.
config_init

# Create a symbolic link to the udev rules file we store
# in the risks directory. This is only done once, when we
# don't detect our symlink to the /etc/udev/rules.d/hush.rules
device.link_hush_udev_rules

# Default filesystem settings from configuration file ----------------------------------------------

typeset -gr SDCARD_ENC_PART="$(config_get SDCARD_ENC_PART)"
typeset -gr SDCARD_ENC_PART_MAPPER="$(config_get SDCARD_ENC_PART_MAPPER)"
typeset -gr SDCARD_QUIET="$(config_get SDCARD_QUIET)"
typeset -gr BACKUP_MAPPER="$(config_get BACKUP_MAPPER)"
typeset -gr HUSH_DIR="$(config_get HUSH_DIR)"
typeset -gr GRAVEYARD="$(config_get GRAVEYARD)"
typeset -gH GPGPASS_TIMEOUT=$(config_get GPGPASS_TIMEOUT)

# Default tombs and corresponding mount points (CONSTANTS) .........................................

typeset -gr GPG_TOMB_LABEL="GPG"          # Stores an identity GPG private keys. Seldom opened
typeset -gr SSH_TOMB_LABEL="ssh"          # Stores SSH keypairs
typeset -gr MGMT_TOMB_LABEL="mgmt"        # Holds the key-value store, and anything the user wants.
typeset -gr PASS_TOMB_LABEL="pass"        # Holds the password store data

typeset -gr FILE_ENCRYPTION="file_encryption_key" # Simply used as site name in spectre call.

# Other default security-related default directories/names .........................................

typeset -gr RAMDISK="${HOME}/.gnupg" 
typeset -gr BACKUP_MOUNT_DIR="/tmp/pendrive"

typeset -gr DEFAULT_KV_USER_DIR="$HOME/.tomb/mgmt/db/"
typeset -gr RISKS_SCRIPTS_INSTALL_PATH="${HUSH_DIR}/.risks"

typeset -gr RISKS_IDENTITY_FILE="${RISKS_DIR}/.identity"

# Other constants ..................................................................................

typeset -gr UDEV_RULES_FILE="risks-hush.rules"
typeset -gr UDEV_RULES_PATH="${RISKS_DIR}/${UDEV_RULES_FILE}" # Contains udev rules for all formatted SDcards

# Password-store
export PASSWORD_STORE_ENABLE_EXTENSIONS=true
export PASSWORD_STORE_GENERATED_LENGTH=20

# Sensitive & and recurring variables used by program ..............................................

typeset -gH IDENTITY
typeset -gH FILE_ENCRYPTION_KEY
typeset -gH GPG_PASS
