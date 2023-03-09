
local resource dest_vm source_dir

resource="${args['resource']}"   # Resource is a tomb file (root directory) in ~/.tomb
dest_vm="${args['dest_vm']}"

identity.set "${args['identity']}"

# Open the related tomb for the tool
_run tomb.open "$resource"
_catch "Failed to open tomb"

# Get the source directory, and copy the files to the VM
_info "Loading data in tomb $resource to VM $dest_vm"
source_dir="${HOME}/.tomb/${resource}"
_info "$(qvm-copy-to-vm "$dest_vm" "${source_dir}/"'*')"

# And close tomb if asked to
if [[ "${args['--close-tomb']}" -eq 1 ]]; then
    _info "Closing tomb"
    _run tomb.close "$resource"
fi
