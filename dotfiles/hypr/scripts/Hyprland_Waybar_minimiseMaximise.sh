#!/bin/bash


# If current=selected AND in minimised workspace, send to non-minimised
# If current=selected and NOT in mimisied workspace, send to minimsed
# If current != selected, pull the window in


# Problem: pulling in special workspace windows from other workspaces' minimised workspaces demands that you have at least one window open in the current workspace (so hyprctl activewindow has something to latch onto)





# the address passed by waybar inclueds 0x infront of the address
windowAddress=$1

# 2 is for middle click
button=$2


# hyprctl notify 0 4000 "rgb(ff0000)" "windowWorkspace: $windowAddress"
# hyprctl notify 0 4000 "rgb(ff0000)" "$button"

hyprctl eval "hl.notification.create({ text = 'WindowAddress: $windowAddress\nbutton: $button', timeout = 1500, icon = "error" })"



# If left click on the window
if (( button == 1 )); then

    # hyprctl notify 0 4000 "rgb(ff0000)" "Switching Focus to Window $windowAddress"

    # Since i run with follow_focus off, i need to turn that on for this to really "focus" on the selected window (so it actually comes into the visible display)
    hyprctl --batch "eval 'hl.config({scrolling = {follow_focus true,}})'; \
                     dispatch 'hl.dsp.window.focus({window = $windowAddress})'; \
                     eval 'hl.config({scrolling = {follow_focus false,}})'"

    exit 0
fi


# If middle mouse button is clicked on the window
if (( button == 2 )); then

    # hyprctl notify 0 4000 "rgb(ff0000)" "Closing Window $windowAddress"

    hyprctl dispatch "hl.dsp.window.close({window = $windowAddress})"

    exit 0
fi




# The workspace info it gets is the one between the paranthesis
currentWorkspace=$(hyprctl activewindow | awk '/workspace:/ { if (match($0, /\(([^)]*)\)/, a)) print a[1] }')

# hyprctl notify 0 4000 "rgb(ff0000)" "CurrentWorkspace: $currentWorkspace"


# This willhappen when activewindow call can't find an activewindow to dispatch on
if [[ "$currentWorkspace" == "" ]]; then

    # hyprctl notify 0 4000 "rgb(ff0000)" "Unable to get the Current Workspace"
    exit 0

fi



selectedWindow_workspace="$(
  hyprctl clients \
    | awk "/Window ${1#0x} /, /workspace:/" \
    | awk '/workspace:/ { if (match($0, /\(([^)]*)\)/, a)) print a[1] }'
)"

# hyprctl notify 0 4000 "rgb(ff0000)" "Selected Workspace: $selectedWindow_workspace"



# get the "1_S" or "1" from "special:1_S" or "1"
currentWorkspace_numeric=${currentWorkspace%%_S}   # -> "special:1"
currentWorkspace_numeric=${currentWorkspace_numeric#*:}  # -> "1"

# get the "1_S" or "1" from "special:1_S" or "1"
selectedWindow_workspace_numeric=${selectedWindow_workspace%%_S}
selectedWindow_workspace_numeric=${selectedWindow_workspace_numeric#*:}

# hyprctl notify 0 4000 "rgb(ff0000)" "currentWorkspace_numeric: $currentWorkspace_numeric"
# hyprctl notify 0 4000 "rgb(ff0000)" "selectedWindow_workspace_numeric: $selectedWindow_workspace_numeric"




# selected Window is in current workspace
if  [[ "$currentWorkspace" == "$selectedWindow_workspace" ]]; then

    # Current workspace is a minimise-workspace
    if [[ "$currentWorkspace" == *_S ]]; then
        # Send it to its Non-Minimise Workspace pair

        # hyprctl notify 0 4000 "rgb(ff0000)" "CurrentWorkspace: $currentWorkspace is a MINIMISE WORKSPACE"

        # We need to see if the current workspace is one of my "Special" workspaces. If it is, it must be sent to workspace with special: tag. If not, it must be sent to the worksapce without special: tag
        # ASSUMPTION: Moving on the assumption that all my non-minimise special workspaces will be ALPHA and, therefore, all normal workspaces will be NUMERIC

        # If currentWorkspace_numeric without the trailing _S is numeric -> Current Workspace is normal workspace's minimise pair
        if [[ "${currentWorkspace_numeric%%_S}" =~ ^[0-9]+$ ]]; then
            # hyprctl notify 0 4000 "rgb(ff0000)" "Selected Workspace is the same as Current Workspace AND currentWorkspace is a normal-Workspace-Minimse Pair - Sending window to its non-minimised pair-workspace: ${currentWorkspace%%_S}"

            hyprctl dispatch 'hl.dsp.window.move({workspace = '${currentWorkspace_numeric%%_S}', follow = false, window = 'address:$windowAddress'})' #Sends it to the workspace of the current window without the _S part

        # If currentWorkspace_numeric without the trailing _S is NOT numeric (=alpha) -> Current Workspace is non-minimise-special workspace's minimise pair
        else
            # hyprctl notify 0 4000 "rgb(ff0000)" "Selected Workspace is the same as Current Workspace AND currentWorkspace is a Special-Workspace-Minimse Pair - Sending window to its non-minimised pair-workspace: ${currentWorkspace%%_S}"

            hyprctl dispatch 'hl.dsp.window.move({workspace = 'special:${currentWorkspace_numeric%%_S}', follow = false, window = 'address:$windowAddress'})' #Sends it to the workspace of the current window without the _S part
        fi

    # Current workspace is a non-minimise-workspace
    else
        # Send it to its Minimise Workspace pair

        # hyprctl notify 0 4000 "rgb(ff0000)" "Selected Workspace is the same as Current Workspace - Sending window to its minimised pair-workspace: special:${currentWorkspace_numeric}_S"

        hyprctl dispatch 'hl.dsp.window.move({workspace = 'special:${currentWorkspace_numeric}_S', follow = false, window = 'address:$windowAddress'})'

    fi


else
    # selected Window is NOT in current workspace
    # Pull the window to the current workspace

    # hyprctl notify 0 4000 "rgb(ff0000)" "Selected workspace is NOT the same as the current workspace - pulling window to $currentWorkspace"

    # This pulls the window to the current workspace be it special or not
    hyprctl dispatch 'hl.dsp.window.move({workspace = '$currentWorkspace', follow = true, window = 'address:$windowAddress'})' # movetoworkspace instead of movetoworkspacesilent because when in a special workspace, when you pull a window in, it switch to the underlying non-special workspace


    # Can add the logic to "If btw 1-10, 1_S-10_S; move it to its pair instead of the current"
fi

exit 0

