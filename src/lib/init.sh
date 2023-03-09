
# This file contains additional IDENTITY initialization functions.

## tomb.create_password_store creates the tomb storing the password-store and sets it up.
# $1 - Email recipient to use for password-store (GPG recipient)
function tomb.create_password_store ()
{
    local email="${1}"

    _verbose "Creating tomb file for pass"
    _run tomb.create "$PASS_TOMB_LABEL" 20 "$IDENTITY"
    _verbose "Opening password store"
    _run tomb.open "$PASS_TOMB_LABEL" "$IDENTITY"
    _verbose "Initializating password store with recipient $email"
    _run pass init "$email"
    _verbose "Closing pass tomb file"
    _run tomb.close "$PASS_TOMB_LABEL" "$IDENTITY"
}

# tomb.create_management creates a default management tomb
# in which, between others, the key=value store is being kept.
function tomb.create_management ()
{
    _verbose "Creating tomb file for management (key=value store, etc)"
    _run tomb.create "$MGMT_TOMB_LABEL" 10 "$IDENTITY"
    _verbose "Opening management tomb"
    _run tomb.open "$MGMT_TOMB_LABEL" "${IDENTITY}"
    _verbose "Closing management tomb"
    _run tomb.close "$MGMT_TOMB_LABEL" "$IDENTITY"
}
