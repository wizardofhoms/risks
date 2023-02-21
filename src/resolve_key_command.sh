
local tomb_key tomb_label

_set_identity "" 

resource="${args[tomb_name]}"
tomb_label="${IDENTITY}-${resource}"

tomb_key=$(_encrypt_filename "$tomb_label.key")
print "${tomb_key}"
