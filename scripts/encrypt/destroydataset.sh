zfs list
read -p "Enter the dataset or pool name to delete: " name && read -p "Type \"$name\" in ALL CAPS to confirm: " confirm && [ "$confirm" = "$(echo $name | tr '[:lower:]' '[:upper:]')" ] && sudo zfs destroy -r "$name"
