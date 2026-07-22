

-- includes
local sharedConstants = require("./scripts/sharedConstants")






---------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------
--------------------------------------------------- Functions -------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------



-- return the active workspace - special or not
local function getActiveWorkspace()

    local activeWorkspace

    local activeNORMALWorkspace = hl.get_active_workspace() 
    local activeSPECIALWorkspace = hl.get_active_special_workspace() 

    -- if in a special workspace
    if activeSPECIALWorkspace then
        activeWorkspace = activeSPECIALWorkspace

    -- if in a non-special workspace
    elseif activeNORMALWorkspace then
        activeWorkspace = activeNORMALWorkspace

    -- should never happen
    else
        hl.notification.create({ text = "INVALID WORKSPACE -- NEITHER SPECIAL OR NORMAL! THIS IS AN ERROR!\nWorkspace: " .. tostring(activeWorkspace) .. "\nSpecial Workspace: ".. tostring(activeSPECIALWorkspace), timeout = 5000, icon = "error" })

    end

    return activeWorkspace
end




-- return true if window's size is ~ the monitor size.
local function windowTakesUpWholeScreen(window)

    if window == nil then
        hl.notification.create({ text = "Window is NIL! This is an error!", timeout = 1500, icon = "error" })
        -- don't return early, let it fail so i get an error notif with which funcion that called this
    end


    -- TODO - these are for VM debugging. This is the size of the VM window.
    -- local screenSize_x = 1280
    -- local screenSize_y = 720

    local screenSize_x = hl.get_active_monitor().width
    local screenSize_y = hl.get_active_monitor().height




    -- -18 is for gaps plus some padding/error margin.
    --     Why that number? exact number should be 12 for x and 14 for y but padding to make sure it's error-resistent
    -- -30 on the height is how tall the top bar is
    local targetSize_x = screenSize_x - 18
    local targetSize_y = screenSize_y - 18 - 30


    if window.group ~= nil then
        -- Window is grouped. we need to account for the size of the groupbar when judging if the window takes up the whole screen or not
        -- Groupbar Compensation: Groupbar '20' tall
        return window.size.x > targetSize_x and window.size.y > (targetSize_y - 20)

    else
        return window.size.x > targetSize_x and window.size.y > targetSize_y
    end
end



-- returns true if the window's left corner is flush with the left side of the display. This means that as much of the window's width as the screen will fit is in view
local function windowCurrentlyComplatelyInView(window)


    if window == nil then
        return false
    end


    if window.group ~= nil then
        -- Window is grouped. We don't need to account for anything when checking its left corner value but this separation is here in case we do
        
        return window.at.x > -120 and window.at.x < 10 and window.at.y < 70

    else 
        -- x < 10 is cuz of the gap. it is normally 7, but i gave it same padding.
        -- -120 < x is cuz of the smallest x of a window when it is on the left and out of view (still focusable by hovering over left corner on 2 colresize 0.5 winows)
        -- y < 70 cuz we don't consider a window to take the whole screen if it has another window in the same col as itself.
        -- NOW, this does not guarantee that there is another window in the same column that is below the window. That needs to be checked by size!
        --    70 is the largest a window can be vertically while having another window in its column that is above it + some padding
        return window.at.x > -120 and window.at.x < 10 and window.at.y < 70
    end
    
end





--- @param apply boolean : true -> @param workspace's gaps_in and gaps_out are set to 0
--                       : false -> @param workspace's gaps_in and gaps_out are set to HYPRLAND_GAPS_IN, HYPRLAND_GAPS_OUT
local function workspaceRule_RemoveGaps(workspace, apply)


    if workspace == nil then
        hl.notification.create({ text = "Workspace is NIL! This is an error!", timeout = 1500, icon = "error" })
        -- don't return early, let it fail so i get an error notif with which funcion that called this
    end


    if apply == true then
        hl.workspace_rule({
            workspace = workspace.name,
            gaps_in = 0,
            gaps_out = 0,
        })

    else 
        hl.workspace_rule({
            workspace = workspace.name,
            gaps_in = sharedConstants.HYPRLAND_GAPS_IN,
            gaps_out = sharedConstants.HYPRLAND_GAPS_OUT,
        })

    end

end





-- returns the window ID for the last focused tiled window in that workspace.
-- Assumes you focused on a tiled window in that workspace at least once in the last 999 focus instances
--- @param tiled boolean
local function getLastTiledOrFloatingWindowInWorkspace(tiled)

    local currentWorkspace = getActiveWorkspace()

    local windowList = hl.get_workspace_windows(currentWorkspace)

    -- assume that you last focused on a tiled window before focusing on 999 floating windows
    local smallestHistoryID = 999
    local smallestHistoryID_Window

    -- find the last focused tiled (or floating depending on the passed parameter) window
    for _, window in ipairs(windowList) do
        if window.floating ~= tiled then -- if tiled param == true, window must not float for that window to be considered
            if window.focus_history_id < smallestHistoryID then
                smallestHistoryID = window.focus_history_id
                smallestHistoryID_Window = window
            end
        end
    end

        
    return smallestHistoryID_Window

end








local function getWindowOnTheRight(window, workspace)

    if window == nil or workspace == nil then
        hl.notification.create({ text = "Window or Workspace is nil! This is an error!", timeout = 1500, icon = "error" })
        return
    end
    

    -- Get the window on the right 
    local currentWindows_x = window.at.x
    local windowList = hl.get_workspace_windows(workspace)
    local candidateWindow = nil
    local smallestFoundBiggerThanCurrentWindows_x = 99999
    -- check all windows for if they could be the underlying "fully in view and takes up the entire monitor" tiled window behind the floating one
    for _, windowElement_FindingTiled in ipairs(windowList) do
        if windowElement_FindingTiled ~= nil and not windowElement_FindingTiled.floating then
            local windowElement_x = windowElement_FindingTiled.at.x
            if windowElement_x > currentWindows_x and windowElement_x < smallestFoundBiggerThanCurrentWindows_x  then
                candidateWindow = windowElement_FindingTiled
                smallestFoundBiggerThanCurrentWindows_x = windowElement_x
            end
        end
    end

    return candidateWindow

end


local function getWindowOnTheLeft(window, workspace)

    if window == nil or workspace == nil then
        hl.notification.create({ text = "Window or Workspace is nil! This is an error!", timeout = 1500, icon = "error" })
        return
    end
    

    -- Get the window on the right 
    local currentWindows_x = window.at.x
    local windowList = hl.get_workspace_windows(workspace)
    local candidateWindow = nil
    local smallestFoundBiggerThanCurrentWindows_x = -99999
    -- check all windows for if they could be the underlying "fully in view and takes up the entire monitor" tiled window behind the floating one
    for _, windowElement_FindingTiled in ipairs(windowList) do
        if windowElement_FindingTiled ~= nil and not windowElement_FindingTiled.floating then
            local windowElement_x = windowElement_FindingTiled.at.x
            if windowElement_x < currentWindows_x and windowElement_x > smallestFoundBiggerThanCurrentWindows_x  then
                candidateWindow = windowElement_FindingTiled
                smallestFoundBiggerThanCurrentWindows_x = windowElement_x
            end
        end
    end

    return candidateWindow

end






return {
    -- Which files to export using which names
    getActiveWorkspace                         = getActiveWorkspace,
    windowTakesUpWholeScreen                   = windowTakesUpWholeScreen,
    windowCurrentlyComplatelyInView            = windowCurrentlyComplatelyInView,
    workspaceRule_RemoveGaps                   = workspaceRule_RemoveGaps,
    getLastTiledOrFloatingWindowInWorkspace    = getLastTiledOrFloatingWindowInWorkspace,
    getWindowOnTheRight                        = getWindowOnTheRight,
    getWindowOnTheLeft                         = getWindowOnTheLeft,

}

