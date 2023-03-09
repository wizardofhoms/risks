
local tomb_file tomb_label resource

identity.set "${args['identity']}"

resource="${args['tomb_name']}"
tomb_label="${IDENTITY}-${resource}"

identity_graveyard=$(graveyard.identity_directory "$IDENTITY")
tomb_file=$(crypt.filename "$tomb_label")

print "${identity_graveyard}/${tomb_file}.tomb"
