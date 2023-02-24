
_set_identity "${args['identity']}"
check_hush_mounted

# Then derive the gpg pass phrase from it, with one-time use,
# needed for all tombs, no matter how many. Only ask for it
# if it is not yet in the GPG agent cache.
if ! is_gpg_passphrase_cached ; then
    GPG_PASS=$(get_passphrase "$GPG_TOMB_LABEL")
    echo -n "$GPG_PASS" | xclip -loops 1 -selection clipboard
    _warning "GPG passphrase copied to clipboard with one-time use only"
fi

_message "Opening coffin and mounting GPG keyring"
open_coffin

_message "Opening Management tomb ... "
_run open_tomb "$MGMT_TOMB_LABEL"

_message "Opening SSH tomb ... "
_run open_tomb "$SSH_TOMB_LABEL"

_message "Opening PASS tomb ..."
_run open_tomb "$PASS_TOMB_LABEL"

_message "Opening Signal tomb ..."
_run open_tomb "$SIGNAL_TOMB_LABEL"
