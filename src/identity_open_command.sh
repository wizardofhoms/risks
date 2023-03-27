
identity.set "${args['identity']}"
hush.fail_device_unmounted

# Derive the gpg pass phrase from it, with one-time use,
# needed for all tombs, no matter how many. Only ask for it
# if it is not yet in the GPG agent cache.
if ! gpg.passphrase_is_cached ; then
    GPG_PASS=$(crypt.passphrase "$GPG_TOMB_LABEL")
    echo -n "$GPG_PASS" | xclip -loops 1 -selection clipboard
    _warning "GPG passphrase copied to clipboard with one-time use only"
fi

_info "Opening coffin and mounting GPG keyring"
gpg.open_coffin

_info "Opening Management tomb ... "
_run tomb.open "$MGMT_TOMB_LABEL"

_info "Opening SSH tomb ... "
_run tomb.open "$SSH_TOMB_LABEL"

_info "Opening PASS tomb ..."
_run tomb.open "$PASS_TOMB_LABEL"
