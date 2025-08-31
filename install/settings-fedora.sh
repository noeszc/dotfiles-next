#!/bin/bash
# GNOME Configuration Script

# Exit immediately if a command exits with a non-zero status.
set -eo pipefail

# --- Helper Function for Logging ---
print_info() {
    echo -e "\n\033[1;34m:: $1\033[0m"
}

# --- Main Configuration Functions ---

cleanup_conflicting_shortcuts() {
    print_info "Cleaning up conflicting default shortcuts..."

    # Clear Super+Space from language switching to free it up for Ulauncher
    gsettings set org.gnome.desktop.wm.keybindings switch-input-source "[]"
    gsettings set org.gnome.desktop.wm.keybindings switch-input-source-backward "[]"

    # Clear Alt+<num> from the default GNOME Terminal (Ptyxis) to free it for app switching
    for i in {1..9}; do
        gsettings set org.gnome.Ptyxis.Shortcuts focus-tab-$i "''"
    done
}

set_window_management() {
    print_info "Setting window management keybindings..."

    # Alt+F4 is very cumbersome
    gsettings set org.gnome.desktop.wm.keybindings close "['<Super>w']"
    # Make it easy to maximize like you can fill left/right
    gsettings set org.gnome.desktop.wm.keybindings maximize "['<Super>Up']"
    # Make it easy to resize undecorated windows
    gsettings set org.gnome.desktop.wm.keybindings begin-resize "['<Super>BackSpace']"
    # Full-screen with title/navigation bar
    gsettings set org.gnome.desktop.wm.keybindings toggle-fullscreen "['<Shift>F11']"
}

set_workspaces_and_apps() {
    print_info "Configuring workspaces and application shortcuts..."

    # Define the number of fixed workspaces
    local NUM_WORKSPACES=6

    # Use fixed workspaces instead of dynamic mode
    gsettings set org.gnome.mutter dynamic-workspaces false
    gsettings set org.gnome.desktop.wm.preferences num-workspaces $NUM_WORKSPACES

    # Use Super + <num> for switching workspaces
    for i in $(seq 1 $NUM_WORKSPACES); do
        gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-$i "['<Super>$i']"
        gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-$i "['<Shift><Super>$i']"
    done

    # Use Alt + <num> for pinned apps in the dash
    for i in {1..9}; do
        gsettings set org.gnome.shell.keybindings switch-to-application-$i "['<Alt>$i']"
    done
}

set_custom_keybindings() {
    print_info "Configuring custom keybindings..."

    # For keyboards that only have a start/stop button for music, like Logitech MX Keys Mini
    gsettings set org.gnome.settings-daemon.plugins.media-keys next "['<Shift>AudioPlay']"
    
    # Define all custom keybindings in an array for easy management.
    # Format: "Name;Command;Binding"
    local CUSTOM_KEYBINDS=(
        "Ulauncher;ulauncher-toggle;<Super>space"
        "New Ghostty Window;ghostty;<Shift><Alt>2"
        "New Chrome Window;google-chrome --new-window;<Shift><Alt>1"
    )

    local keybinding_paths=()
    local index=0
    for bind in "${CUSTOM_KEYBINDS[@]}"; do
        IFS=';' read -r name command binding <<< "$bind"
        local path="/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom${index}/"
        
        gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:"$path" name "$name"
        gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:"$path" command "$command"
        gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:"$path" binding "$binding"
        
        keybinding_paths+=("'$path'")
        ((index++))
    done

    # Apply the list of custom keybindings to the system
    local final_list
    final_list=$(IFS=,; echo "${keybinding_paths[*]}")
    gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings "[${final_list}]"
}

# --- Main Execution ---
main() {
    # Ensure gsettings command is available
    if ! command -v gsettings &> /dev/null; then
        echo "Error: 'gsettings' not found. This script requires a GNOME environment." >&2
        exit 1
    fi

    echo "Starting personalized GNOME configuration..."
    
    cleanup_conflicting_shortcuts
    set_window_management
    set_workspaces_and_apps
    set_custom_keybindings
    
    print_info "GNOME configuration complete!"
    echo "Please restart GNOME Shell (Alt+F2, r, Enter) or log out and back in to apply all changes."
}

main
