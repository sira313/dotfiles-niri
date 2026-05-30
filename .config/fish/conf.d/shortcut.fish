# Create snapshot
function snap --description 'Create a btrfs snapshot interactively with snapper'
    read -P "Enter snapshot description: " description
    if test -z "$description"
        echo "Error: Description cannot be empty."
        return 1
    end

    echo "Creating snapshot for config 'root'..."
    sudo snapper -c root create -d "$description"

    if test $status -eq 0
        echo "Snapshot created successfully."
    else
        echo "Failed to create snapshot."
    end
end

# View snapshot list
function snap-list --description 'Show snapper root snapshot list'
    sudo snapper -c root list
end

# Delete unused snapshot
function snap-del --description 'Delete a snapper root snapshot by number'
    if test (count $argv) -eq 0
        echo "Usage: snap-del <snapshot_number>"
        return 1
    end

    set -l number $argv[1]

    read -P "Are you sure you want to delete snapshot number $number? [y/N]: " confirm

    if test "$confirm" = "y" -o "$confirm" = "Y"
        echo "Deleting snapshot $number..."
        sudo snapper -c root delete $number

        if test $status -eq 0
            echo "Snapshot $number deleted successfully."
        else
            echo "Failed to delete snapshot $number."
        end
    else
        echo "Operation cancelled."
    end
end

# Fix CPU throttle
function fixcpu --description 'Fix AMD Ryzen throttling by overriding power limits'
    echo "Attempting to remove CPU power limits..."

    # Run ryzenadj with tested parameters
    sudo ryzenadj --stapm-limit=25000 --fast-limit=25000 --slow-limit=25000

    if test $status -eq 0
        echo "Success! Checking current CPU frequencies..."

        # Display current CPU frequencies briefly
        grep "cpu MHz" /proc/cpuinfo | head -n 4
    else
        echo "Failed to run ryzenadj. Make sure your sudo password is correct."
    end
end

# Enable samba share for Public dir
function share-on
    sudo systemctl start smb nmb

    if test $status -eq 0
        notify-send 'Samba Server' 'Public folder sharing enabled' -i network-server
        echo "Samba started successfully."
    end
end

# Disable samba share
function share-off
    sudo systemctl stop smb nmb

    if test $status -eq 0
        notify-send 'Samba Server' 'Sharing stopped' -i network-offline
        echo "Samba stopped successfully."
    end
end

# Clear clipboard history
function clip-wipe --description 'Clear all cliphist clipboard history'
    rm ~/.cache/cliphist/db && notify-send "Clipboard" "History cleared!"

    if test $status -eq 0
        echo "Clipboard history wiped clean."
    end
end