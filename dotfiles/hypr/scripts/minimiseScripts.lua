
-- includes
local sharedScripts = require("./scripts/sharedScripts")






local function minimiseKeybinding()
    
    local currentWorkspace = sharedScripts.getActiveWorkspace()


    if currentWorkspace == nil then
        hl.notification.create({ text = "Current Workspace is NIL! This is an error!", timeout = 1500, icon = "error" })
        return
    end


    -- If not special, it'll be just the name. If it is special it'll have "special:" at the beginning of it
    local currentWorkspace_Name = nil


    if currentWorkspace.special then
        -- will remove the "special:" part
        currentWorkspace_Name = currentWorkspace.config_name:match("special:(.+)")
    else
        currentWorkspace_Name = currentWorkspace.config_name
    end


    if currentWorkspace_Name == nil then
        hl.notification.create({ text = "Failed to get the name of the current workspace!", timeout = 1500, icon = "error" })
        return
    end



    -- check if the workspace is a minimise workspace: does it end with "_S"?
    local isMinimiseWorkspace = currentWorkspace_Name:sub(-2) == "_S"



    -- send it to its minimised pair: A special worksapce that has a "_S" tagged at the end of the currentWorkspace's name
    if not isMinimiseWorkspace then
        hl.dispatch(hl.dsp.window.move({ workspace = "special:" .. currentWorkspace_Name .. "_S", follow = false}))
        return
    end



    -- The workspace is a minimise-worksapce. We must send this window to its non-minimise-workspace pair

    -- See if the workspace we are to send this to is special or not
    -- If the workspace is numeric (1,2,9,...,999), it is normal.
    -- If the workspace is Alpha (A,B,C), it is Special.
    -- Simply check if it is not numeric:
    local isTargetWorkspaceSpecial = tonumber(currentWorkspace_Name:sub(1, -3)) == nil



    if isTargetWorkspaceSpecial then    
        -- send to the special workspace without the _S
        hl.dispatch(hl.dsp.window.move({ workspace = "special:" .. currentWorkspace_Name:sub(1, -3), follow = false}))
    else
        -- send to the normal workspace without the _S
        hl.dispatch(hl.dsp.window.move({ workspace = currentWorkspace_Name:sub(1, -3), follow = false}))
    end


end




local function minimiseGoToMinimisedWorkspace()
   


    local currentWorkspace = sharedScripts.getActiveWorkspace()


    if currentWorkspace == nil then
        hl.notification.create({ text = "Current Workspace is NIL! This is an error!", timeout = 1500, icon = "error" })
        return
    end


    -- If not special, it'll be just the name. If it is special it'll have "special:" at the beginning of it
    local currentWorkspace_Name = nil


    if currentWorkspace.special then
        -- will remove the "special:" part
        currentWorkspace_Name = currentWorkspace.config_name:match("special:(.+)")
    else
        currentWorkspace_Name = currentWorkspace.config_name
    end


    if currentWorkspace_Name == nil then
        hl.notification.create({ text = "Failed to get the name of the current workspace!", timeout = 1500, icon = "error" })
        return
    end



    -- check if the workspace is a minimise workspace: does it end with "_S"?
    local isMinimiseWorkspace = currentWorkspace_Name:sub(-2) == "_S"



    -- Switch workspace to its minimised pair
    if not isMinimiseWorkspace then
        hl.dispatch(hl.dsp.focus({ workspace = "special:" .. currentWorkspace_Name .. "_S", on_current_monitor = true}))
        return
    end



    -- The workspace is a minimise-worksapce.

    -- See if the workspace we are to switch to is special or not
    -- If the workspace is numeric (1,2,9,...,999), it is normal.
    -- If the workspace is Alpha (A,B,C), it is Special.
    -- Simply check if it is not numeric:
    local isTargetWorkspaceSpecial = tonumber(currentWorkspace_Name:sub(1, -3)) == nil



    if isTargetWorkspaceSpecial then    
        -- focus to the special workspace without the _S
        hl.dispatch(hl.dsp.focus({ workspace = "special:" .. currentWorkspace_Name:sub(1, -3), on_current_monitor = true}))
    else
        -- focus to the normal workspace without the _S
        hl.dispatch(hl.dsp.focus({ workspace = currentWorkspace_Name:sub(1, -3), on_current_monitor = true}))
    end


    
end







return {
    minimiseKeybinding = minimiseKeybinding,
    minimiseGoToMinimisedWorkspace = minimiseGoToMinimisedWorkspace,
}

