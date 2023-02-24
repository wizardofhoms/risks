
# _set_identity is used to propagate our various IDENTITY related variables
# so that all functions that will be subsequently called can access them.
#
# This function also takes care of checking if there is already an active
# identity that should be used, in case the argument is empty or none.
#
# $1 - The identity to use.
_set_identity () {
    local identity="$1"

    # This will throw an error if we don't have an identity from any source.
    IDENTITY=$(_identity_active_or_specified "$identity")
    _catch "Command requires either an identity to be active or given as argument"

    # Then set the file encryption key for for it.
    FILE_ENCRYPTION_KEY=$(_set_file_encryption_key "$IDENTITY")
}

# Upon unlocking a given identity, sets the name as an ENV 
# variable that we can use in further functions and commands.
# $1 - The name to use. If empty, just resets the identity.
_set_active_identity ()
{
    # If the identity is empty, wipe the identity file
    if [[ -z ${1} ]] && [[ -e ${RISKS_IDENTITY_FILE} ]]; then
        identity=$(cat "${RISKS_IDENTITY_FILE}")
        _run wipe -s -f -P 10 "${RISKS_IDENTITY_FILE}" || _warning "Failed to wipe identity file !"

        _verbose "Identity '${identity}' is now inactive, (name file deleted)"
        _info "Identity '${identity}' is now INACTIVE"
        return
    fi

    # If we don't have a file containing the 
    # identity name, populate it.
    if [[ ! -e ${RISKS_IDENTITY_FILE} ]]; then
        print "$1" > "${RISKS_IDENTITY_FILE}"
    fi

    _verbose "Identity '${1}' is now active (name file written)"
    _info "Identity '${1}' is now ACTIVE"
}

# Returns 0 if an identity is unlocked, 1 if not.
_identity_active () 
{
    local identity

    if [[ ! -e "${RISKS_IDENTITY_FILE}" ]]; then
        return 1
    fi

    identity=$(cat "${RISKS_IDENTITY_FILE}")
    if [[ -z ${identity} ]]; then
        return 1
    fi

    return 0
}

# check_identity_active exits the program 
# if there is identity, active or specified. 
check_identity_active ()
{
    if ! _identity_active ; then
        _failure "This command requires an identity to be active"
    fi
}

# Given an argument potentially containing the active identity, checks
# that either an identity is active, or that the argument is not empty.
# $1 - An identity name
# Exits the program if none is specified, or echoes the identity if found.
# Returns:
# 0 - Identity is non-nil, provided either from arg or by the active
# 1 - None have been given
_identity_active_or_specified ()
{
    if [[ -z "${1}" ]] ; then
        if ! _identity_active ; then
            return 1
        fi
    fi

    # Print the identity
    if [[ -n "${1}" ]]; then
        print "${1}" && return
    fi

    print "$(cat "${RISKS_IDENTITY_FILE}")"
}

# _get_name either returns the name given as parameter, or
# generates a random (burner) one and prints it to the screen.
_get_name () 
{
    local name

    if [[ -z "${1}" ]] && [[ "${args['--burner']}" -eq 0 ]]; then
        _failure "Either an identity name is required, or the --burner flag" 
    fi

    # Either use the provided one
    if [[ -n "${1}" ]]; then
        name="${1}"
    elif [[ "${args['--burner']}" -eq 1 ]]; then
        name="$(rig -m | head -n 1)"
        name="${name// /_}"
    fi

    print "${name}"
}

# _get_mail returns a correctly formatted mail given either a fully specified 
# one as positional, or a generated/concatenated one from the username argument.
_get_mail ()
{
    local name="$1"
    local email="$2"

    [[ -n "${email}" ]] && print "${email}" && return

    email="${args['--mail']}"
    [[ -n "${email}" ]] && print "${name}@${email}"
}

# _get_expiry returns a correctly formatted expiry date for a GPG key.
# If no arguments are passed to the call, the expiry date is never.
_get_expiry () 
{
    local expiry

    if [[ -z "${1}" ]]; then
        expiry_date="never"
    else
        expiry="${1}"
        expiry_date="$(date +"%Y-%m-%d" --date="${expiry}")" 
    fi

    print "${expiry_date}"
}
