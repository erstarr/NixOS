
-- includes
local sharedConstants = require("./scripts/sharedConstants")
local sharedScripts = require("./scripts/sharedScripts")








---------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------
--------------------------------------------------- Functions -------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------


local scroll_wholeScreenTag = "scroll_MaximiseCandidate"




local function scroll_windowTakeUpWholeColumn(window)

    -- TODO - these are for VM debugging. This is the size of the VM window.
    -- local screenSize_y = 720

    local screenSize_y = hl.get_active_monitor().height

    local targetSize_y = screenSize_y - 18 - 30


    -- the values are synced with sharedScripts.windowTakesUpWholeScreen() --- Must update these if those change

    if window.group ~= nil then
        -- Window is grouped. we need to account for the size of the groupbar when judging if the window takes up the whole screen or not
        -- Groupbar Compensation: Groupbar '20' tall
        return window.size.y > (targetSize_y - 20)

    else
        return window.size.y > targetSize_y
    end

end




local function scroll_execPropRefreshImmediately()

    -- on 0.56 when the workspace changes apply changed. It schedules a prop refresh event and execs it at the end of the current event.
    -- This helper function executes it immediately instead (removes the queued event too)
    hl.dispatch(hl.dsp.layout("inhibit_scroll true"))
    hl.exec_scheduled_prop_refresh_immediately()
    hl.dispatch(hl.dsp.layout("inhibit_scroll false"))


end




-- enact the window/fullscreen modifications for my custom "maximised" kinda behaviour in scrolling layout
local function scroll_enactWindowWorkspaceModifications(currentWindow, currentWorkspace, enact)

    if currentWindow == nil then
        hl.notification.create({ text = "Window is NIL! This is an error!", timeout = 1500, icon = "error" })
        -- don't return early, let it fail so i get an error notif with which funcion that called this
    end
    if currentWorkspace == nil then
        hl.notification.create({ text = "Workspace is NIL! This is an error!", timeout = 1500, icon = "error" })
        -- don't return early, let it fail so i get an error notif with which funcion that called this
    end


    if enact then
        -- Add the tag which is responsible for removing the window's borders and rounding by windowrule
        hl.dispatch(hl.dsp.window.tag({tag = "+" .. scroll_wholeScreenTag, window = currentWindow}))
        -- get rid of gaps for workspace
        sharedScripts.workspaceRule_RemoveGaps(currentWorkspace,true)

        -- immediately apply the changes (go to function def to learn what this means)
        scroll_execPropRefreshImmediately()
       
    else
        -- remove the tag which is responsible for removing the window's borders and rounding by windowrule
        hl.dispatch(hl.dsp.window.tag({tag = "-" .. scroll_wholeScreenTag, window = currentWindow}))
        -- give back gaps for workspace
        sharedScripts.workspaceRule_RemoveGaps(currentWorkspace,false)

        -- immediately apply the changes (go to function def to learn what this means)
        scroll_execPropRefreshImmediately()

    end


end




---------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------
---------------------------------------------------- Scripts --------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------



-- Track if a prop refresh was executed already as a result of switching to the window on the left/right col. This is to prevent redundantly setting the window's properties again in window.active
local propRefreshAppliedDueToWindowSwitch = false





-- Script for moving view and focusing to the right column.
-- ALSO SERVER A MONOCLE KEYBIND -- TODO: Don't use this exact function for monocle. Figure out a way to detect if the current workspace is monocle, and if it is: disable this keybind and use a monocle bind.
-- Then, also modify this function and remove the "if monocle do this" part
local function scroll_focusRight()
    
    local currentWorkspace = sharedScripts.getActiveWorkspace()
    local currentWindow = hl.get_active_window()

    if currentWindow == nil then
        hl.notification.create({ text = "Selected Window was nil! This is an error!", timeout = 2000, icon = "error" })
        return
    end

    if currentWorkspace == nil then
        hl.notification.create({ text = "Selected Workspace was nil! This is an error!", timeout = 2000, icon = "error" })
        return
    end

    -- if the current layout is monocle, it cycles to the next window
    if (currentWorkspace.tiled_layout == "monocle") then
        hl.dispatch(hl.dsp.layout("cyclenext"))
        return
    -- if the current workspace's layout is not scrolling, don't do anything
    elseif (currentWorkspace.tiled_layout ~= "scrolling") then
        hl.notification.create({ text = "Dispatched scrolling/monocle layout specific key in a non-scrolling/non-monocle workspace!", timeout = 1000, icon = "warning" })
        return
    end

    -- if the current window is a Default Handled fullscreened window, dispel that first
    if currentWindow.fullscreen == 1 then
        if currentWindow.fullscreen_handler == "default" then
            hl.dispatch(hl.dsp.window.fullscreen({mode = "maximized", action = "unset", window = currentWindow }))
            currentWindow = hl.get_active_window() -- just in case
        end
    elseif currentWindow.fullscreen == 2 then
        if currentWindow.fullscreen_handler == "default" then
            hl.dispatch(hl.dsp.window.fullscreen({mode = "fullscreen", action = "unset", window = currentWindow }))
            currentWindow = hl.get_active_window() -- just in case
        end
    end


    -- If floating, get the last focused tiled window in the current workspace and switch focus to it
    if currentWindow.floating then
        -- get the last focused tiled window in this workspace, set that as the current window
        currentWindow = sharedScripts.getLastTiledOrFloatingWindowInWorkspace(true)
        if not currentWindow then
            return
        end
        hl.dispatch(hl.dsp.focus({window = currentWindow}))
    end

    -- if the focused window is partially hidden to the right, but it's "maximised" size; fit it to view
    if sharedScripts.windowTakesUpWholeScreen(currentWindow) and  currentWindow.at.x > 10 then
        scroll_enactWindowWorkspaceModifications(currentWindow, currentWorkspace, true)
        -- fit it fully to view - just in case in case
        hl.dispatch(hl.dsp.layout("fit active"))

        -- so the cursor warps to the center of the window
        hl.dispatch(hl.dsp.focus({window = currentWindow}))
        return
    end


    local windowOnTheRight = sharedScripts.getWindowOnTheRight(currentWindow, currentWorkspace)

    if windowOnTheRight == nil then
        return
    end

    local currentWindowMaximise_Sized = sharedScripts.windowTakesUpWholeScreen(currentWindow) and sharedScripts.windowCurrentlyComplatelyInView(currentWindow)
    local rightWindowMaximised = sharedScripts.windowTakesUpWholeScreen(windowOnTheRight)

    if (currentWindowMaximise_Sized ~= rightWindowMaximised) then
        -- Reapply modifications so that the offset is correctly calculated when we switch to the window in <direction>
        scroll_enactWindowWorkspaceModifications(currentWindow, currentWorkspace, false)
    end


    -- move to the window on the right
    hl.dispatch(hl.dsp.layout("focus right"))
    -- update the currentWindow with the new current window
    currentWindow = hl.get_active_window()
    
    -- if the window's size is ~ the monitor size AND the left corner is flush with the left corner of the monitor (i.e. the window takes up the entire screen)
    if sharedScripts.windowTakesUpWholeScreen(currentWindow) and sharedScripts.windowCurrentlyComplatelyInView(currentWindow) then
        scroll_enactWindowWorkspaceModifications(currentWindow, currentWorkspace, true)
        -- fit it fully to view - just in case in case
        hl.dispatch(hl.dsp.layout("fit active"))
    else
        -- give the workspace back its gaps
        scroll_enactWindowWorkspaceModifications(currentWindow, currentWorkspace, false)
    end
    propRefreshAppliedDueToWindowSwitch = true
end









-- Script for moving view and focusing to the LEFT column.
-- ALSO SERVER A MONOCLE KEYBIND -- TODO: Don't use this exact function for monocle. Figure out a way to detect if the current workspace is monocle, and if it is: disable this keybind and use a monocle bind.
-- Then, also modify this function and remove the "if monocle do this" part
local function scroll_focusLeft()
    

    local currentWorkspace = sharedScripts.getActiveWorkspace()
    local currentWindow = hl.get_active_window()

    if currentWindow == nil then
        hl.notification.create({ text = "Selected Window was nil! This is an error!", timeout = 2000, icon = "error" })
        return
    end

    if currentWorkspace == nil then
        hl.notification.create({ text = "Selected Workspace was nil! This is an error!", timeout = 2000, icon = "error" })
        return
    end

    -- if the current layout is monocle, it cycles to the previous window
    if (currentWorkspace.tiled_layout == "monocle") then
        hl.dispatch(hl.dsp.layout("cycleprev"))
        return
    -- if the current workspace's layout is not scrolling, don't do anything
    elseif (currentWorkspace.tiled_layout ~= "scrolling") then
        hl.notification.create({ text = "Dispatched scrolling/monocle layout specific key in a non-scrolling/non-monocle workspace!", timeout = 1000, icon = "warning" })
        return
    end

    -- if the current window is a Default Handled fullscreened window, dispel that first
    if currentWindow.fullscreen == 1 then
        if currentWindow.fullscreen_handler == "default" then
            hl.dispatch(hl.dsp.window.fullscreen({mode = "maximized", action = "unset", window = currentWindow }))
            currentWindow = hl.get_active_window() -- just in case
        end

    elseif currentWindow.fullscreen == 2 then
        if currentWindow.fullscreen_handler == "default" then
            hl.dispatch(hl.dsp.window.fullscreen({mode = "fullscreen", action = "unset", window = currentWindow }))
            currentWindow = hl.get_active_window() -- just in case
        end
    end


    -- If floating, get the last focused tiled window in the current workspace and switch focus to it
    if currentWindow.floating then
        -- get the last focused tiled window in this workspace, set that as the current window
        currentWindow = sharedScripts.getLastTiledOrFloatingWindowInWorkspace(true)
        if not currentWindow then
            return
        end
        hl.dispatch(hl.dsp.focus({window = currentWindow}))
    end

    -- if the focused window is partially hidden to the left, but it's "maximised" size; fit it to view
    if sharedScripts.windowTakesUpWholeScreen(currentWindow) and  currentWindow.at.x < -10 then
        scroll_enactWindowWorkspaceModifications(currentWindow, currentWorkspace, true)
        -- fit it fully to view - just in case in case
        hl.dispatch(hl.dsp.layout("fit active"))

        -- so the cursor warps to the center of the window
        hl.dispatch(hl.dsp.focus({window = currentWindow}))
        return
    end


    local windowOnTheLeft = sharedScripts.getWindowOnTheLeft(currentWindow, currentWorkspace)

    if windowOnTheLeft == nil then
        return
    end

    local currentWindowMaximise_Sized = sharedScripts.windowTakesUpWholeScreen(currentWindow) and sharedScripts.windowCurrentlyComplatelyInView(currentWindow)
    local rightWindowMaximised = sharedScripts.windowTakesUpWholeScreen(windowOnTheLeft)

    if (currentWindowMaximise_Sized ~= rightWindowMaximised) then
        -- Reapply modifications so that the offset is correctly calculated when we switch to the window in <direction>
        scroll_enactWindowWorkspaceModifications(currentWindow, currentWorkspace, false)
    end


    -- move to the window on the right
    hl.dispatch(hl.dsp.layout("focus left"))
    -- update the currentWindow with the new current window
    currentWindow = hl.get_active_window()
    
    -- if the window's size is ~ the monitor size AND the left corner is flush with the left corner of the monitor (i.e. the window takes up the entire screen)
    if sharedScripts.windowTakesUpWholeScreen(currentWindow) and sharedScripts.windowCurrentlyComplatelyInView(currentWindow) then
        scroll_enactWindowWorkspaceModifications(currentWindow, currentWorkspace, true)
        -- fit it fully to view - just in case in case
        hl.dispatch(hl.dsp.layout("fit active"))
    else
        -- give the workspace back its gaps
        scroll_enactWindowWorkspaceModifications(currentWindow, currentWorkspace, false)
    end
    propRefreshAppliedDueToWindowSwitch = true
end



local function scroll_scrollSpecificMaximse()
    
    local currentWorkspace = sharedScripts.getActiveWorkspace()
    local currentWindow = hl.get_active_window()

    if currentWindow == nil then
        hl.notification.create({ text = "Selected Window was nil! This is an error!", timeout = 2000, icon = "error" })
        return
    end

    if currentWorkspace == nil then
        hl.notification.create({ text = "Selected Workspace was nil! This is an error!", timeout = 2000, icon = "error" })
        return
    end


    -- if the current workspace's layout is not scrolling, don't do anything
    if (currentWorkspace.tiled_layout ~= "scrolling") then
        hl.notification.create({ text = "Dispatched scrolling layout specific key in a non-scrolling workspace!", timeout = 1000, icon = "warning" })
        return
    end

    -- If floating, don't do anything
    if currentWindow.floating then
        return
    end

    -- if the current window is a fullscreened window, dispel it and that's it
    if currentWindow.fullscreen == 1 then
        hl.dispatch(hl.dsp.window.fullscreen({mode = "maximized", action = "unset", window = currentWindow }))
        return
    elseif currentWindow.fullscreen == 2 then
        hl.dispatch(hl.dsp.window.fullscreen({mode = "fullscreen", action = "unset", window = currentWindow }))
        return
    end


    -- if the window's size is ~ the monitor size AND the left corner is flush with the left corner of the monitor (i.e. the window takes up the entire screen)
    if sharedScripts.windowTakesUpWholeScreen(currentWindow) then
        scroll_enactWindowWorkspaceModifications(currentWindow, currentWorkspace, false)
        -- revert to half screen size
        hl.dispatch(hl.dsp.layout("colresize 0.5"))
    else

        -- If window is not the only one in its column
        if not scroll_windowTakeUpWholeColumn(currentWindow) then
            return
        end



        scroll_enactWindowWorkspaceModifications(currentWindow, currentWorkspace, true)
        -- fit it fully to view - just in case in case
        hl.dispatch(hl.dsp.layout("fit active"))

    end


end








-- -- Use this to see if more than one prop refresh is being enacted when it shouldn't
-- hl.on("config.props_refreshed", function(int)
--         hl.notification.create({ text = "Prop Refreshed! \nAs Scheduled: " .. tostring(int), timeout = 1500, icon = "error" })

-- end)



hl.on("window.active", function(window, int)

    
    local workspace = sharedScripts.getActiveWorkspace()
    
    -- if the window is nil
    if window == nil then
        hl.notification.create({ text = "Window is NIL! This is an error! \nINT: " .. tostring(int), timeout = 1500, icon = "error" })
        return
    end
    
    
    -- guard against window not being nil but all its fields being nill when changing to another workspace.
    -- TODO - This is a circumstantial error and may be fixed in the coming updates
    if window.address == nil then
        return
    end
    
    
    -- if the workspace is nil
    if workspace == nil then
        hl.notification.create({ text = "Workspace is NIL! This is an error! \nINT: " .. tostring(int), timeout = 1500, icon = "error" })
        return
    end
    
    
    -- if the current workspace's layout is not scrolling, don't do anything
    if (workspace.tiled_layout ~= "scrolling") then
        return
    end
    

    -- if current window is fullscreen or current workspace has a covering fullscreen window, don't consider it.
    if (window.fullscreen ~= 0) or (workspace.has_fullscreen)then
        return
    end
    

    
    local currentlyInViewWindow_thatIsScrollMaximised = nil

    local windowList = hl.get_workspace_windows(workspace)

    -- if the window is floating, we must check for and get the tiling window behind the floating window and check if that is a candidate for being considered a
    -- "fully in view and takes up the entire monitor" window
    if window.floating then


        -- check all windows for if they could be the underlying "fully in view and takes up the entire monitor" tiled window behind the floating one
        for _, windowElement_FindingTiled in ipairs(windowList) do
            
            -- consider a window only if it is tiling. check if the window qualifies.
            if windowElement_FindingTiled ~= nil and sharedScripts.windowTakesUpWholeScreen(windowElement_FindingTiled) and sharedScripts.windowCurrentlyComplatelyInView(windowElement_FindingTiled) and not windowElement_FindingTiled.floating then
                
                -- make that window the window that we are considering as "rightfully has tag".
                currentlyInViewWindow_thatIsScrollMaximised = windowElement_FindingTiled

                -- reenact modifs on it, even if the tag is already there (just in case) -- here we are focused on a floating window still! we are enacting modifs on the tiling window but the focus is still
                -- on the floating window!
                scroll_enactWindowWorkspaceModifications(currentlyInViewWindow_thatIsScrollMaximised,workspace,true)
            end
        end


    else
        -- if the window is tiling

        -- if the window currently in view and takes up the entire monitor AND window is NOT floating
        if sharedScripts.windowTakesUpWholeScreen(window) and sharedScripts.windowCurrentlyComplatelyInView(window) then
        
            -- reenact modifs on it, even if the tag is already there (just in case)
            
            -- If we moved to right/left col in this event, doing this again is pointless
            if not propRefreshAppliedDueToWindowSwitch then
                scroll_enactWindowWorkspaceModifications(window,workspace,true)
                -- fit it fully to view - just in case in case
                -- this should only happen to the window that's currently fully in view anyway so it shouldn't cause weird behaviour
                hl.dispatch(hl.dsp.layout("fit active"))
            end

            -- Save the fact that this window rightfully has the tag.
            -- If the var is nil, this means that there is no scroll_maximised window in view right now and the current workspace must not have any windows that has the tag
            currentlyInViewWindow_thatIsScrollMaximised = window
        else
            -- If we moved to right/left col in this event, doing this again is pointless
            if not propRefreshAppliedDueToWindowSwitch then
                scroll_enactWindowWorkspaceModifications(window,workspace,false)
            end
        end
        
    end


        

    -- check all the windows in the current workspace. If any of them has the tag, it MUST be the one that is complately in view.
    -- If any have the tag, yet not that one, remove the tag from it
    for _, windowElement in ipairs(windowList) do
        if windowElement.tags == nil then
            hl.notification.create({ text = "tags of a window is nil! This is a bug!", timeout = 1500, icon = "error" })
            
        else

            local tags = type(windowElement.tags) == "string" and {windowElement.tags} or windowElement.tags
            for i = 1, #tags do
                if tags[i] == scroll_wholeScreenTag then
                    
                    -- a floating window has the tag. This should NEVER happen
                    if windowElement.floating then
                        hl.dispatch(hl.dsp.window.tag({tag = "-" .. scroll_wholeScreenTag, window = windowElement}))
                        if not currentlyInViewWindow_thatIsScrollMaximised then
                            -- null guard
                            -- Probably mouse grabbed a window that is scroll_maximised
                        else
                            hl.notification.create({ text = "A floating window has the ".. scroll_wholeScreenTag .. " tag! This is a bug!", timeout = 1500, icon = "error" })
                        end
                    end
                    
                    -- A window has the tag although it should not. Strip it from the window!
                    if windowElement ~= currentlyInViewWindow_thatIsScrollMaximised then
                        hl.dispatch(hl.dsp.window.tag({tag = "-" .. scroll_wholeScreenTag, window = windowElement}))
                    end
                end
            end
        end
    end
    
    -- After the current event (assuming window.active can only fire once per event here!), reset the flag
    propRefreshAppliedDueToWindowSwitch = false
end)






---------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------
------------------------------------------------ Workspace Rules ----------------------------------------------------
---------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------




hl.window_rule({
  name = "scrolling_removeBordersAndRounding",
  match = {
    tag = scroll_wholeScreenTag
  },
  border_size = 0,
  rounding = 0,
})







return {
    -- Which files to export using which names
    scroll_enactWindowWorkspaceModifications = scroll_enactWindowWorkspaceModifications,

    scroll_focusRight                        = scroll_focusRight,
    scroll_focusLeft                         = scroll_focusLeft,
    scroll_scrollSpecificMaximse             = scroll_scrollSpecificMaximse,
}
