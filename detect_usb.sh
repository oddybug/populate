#!/bin/bash

MOUNT_POINT="/mnt/usb"

cleanup() {
    if mountpoint -q "$MOUNT_POINT"; then
        echo "[-] Unmounting $MOUNT_POINT..."
        sudo umount "$MOUNT_POINT"
    fi
}
trap cleanup EXIT

detect_device() {
    echo "Waiting for USB drive with label 'oddy'..." >&2

    coproc MONITOR { udisksctl monitor 2>/dev/null; }
    local monitor_pid=$MONITOR_PID

    trap "kill $monitor_pid 2>/dev/null" RETURN

    while read -r line <&${MONITOR[0]}; do
        echo "$line" | grep -qE "Added.*block_devices/sd[a-z][0-9]" || continue

        device_path=$(echo "$line" | grep -oE "block_devices/sd[a-z][0-9]")
        [[ -n "$device_path" ]] || continue

        local dev_name="/dev/$(basename "$device_path")"

        local label
        label=$(lsblk -no LABEL "$dev_name" 2>/dev/null | xargs)

        if [[ "$label" != "oddy" ]]; then
            echo "[-] Found partition $dev_name, but label is '$label' (waiting for 'oddy')..." >&2
            continue
        fi

        echo "[+] Detected target partition 'oddy' at: $dev_name" >&2

        sudo mkdir -p "$MOUNT_POINT"
        if sudo mount "$dev_name" "$MOUNT_POINT" 2>/dev/null; then
            local mount_path="$MOUNT_POINT"

            [[ -n "$mount_path" && -d "$mount_path" ]] || continue

            echo "Successfully mounted at: $mount_path" >&2
            kill "$monitor_pid" 2>/dev/null

            echo "$mount_path"
            return 0
        fi
    done
}

check_directories() {
    local mount_path="$1"
    [[ -d "$mount_path/.ssh" ]] && echo "-> Found '.ssh' directory!"
    [[ -f "$mount_path/.zshrc" ]] && echo "-> Found '.zshrc' file!"
}

copy_ssh() {
    local mount_path="$1"
    local target_ssh="$HOME/.ssh"

    if [[ -d "$mount_path/.ssh" ]]; then
        echo "Copying .ssh directory to $target_ssh..."

        mkdir -p "$target_ssh"
        sudo cp -a "$mount_path/.ssh/." "$target_ssh/"

        echo "Setting correct SSH permissions..."
        sudo chown -R "$USER:$USER" "$target_ssh"
        chmod 700 "$target_ssh"
        find "$target_ssh" -type f -exec chmod 600 {} +
        find "$target_ssh" -type d -exec chmod 700 {} +

        chmod 644 "$target_ssh"/*.pub "$target_ssh"/known_hosts* 2>/dev/null
        echo ".ssh files successfully copied and secured."
    else
        echo "No .ssh directory found to copy."
    fi
}

copy_misc_zsh() {
    local mount_path="$1"
    local target_zsh="$HOME/.zshrc"

    if [[ -f "$mount_path/.zshrc" ]]; then
        echo "Copying .zshrc to $target_zsh..."

        sudo cp "$mount_path/.zshrc" "$target_zsh"

        echo "Setting correct Zsh configuration permissions..."
        sudo chown "$USER:$USER" "$target_zsh"
        chmod 644 "$target_zsh"
        echo ".zshrc successfully copied and configured."
	chsh -s "$(which zsh)"
        echo ".zshrc successfully set up as default."
    else
        echo "No .zshrc file found to copy."
    fi
}

mounted_path=$(detect_device)

if [[ -n "$mounted_path" ]]; then
    sudo chown "$USER" "$mounted_path"

    echo "Listing contents of $mounted_path:"
    ls -la "$mounted_path"

    check_directories "$mounted_path"
    copy_ssh "$mounted_path"
    copy_misc_zsh "$mounted_path"

else
    echo "[-] Device detection failed or timed out." >&2
fi
