
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
