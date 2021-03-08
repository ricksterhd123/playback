--[[
    Author: exile

    Orbitcam script
    For now it uses keyboard binding to rotate the camera around but in later versions it should 
    use mouse movements.
]]
local screenW, screenH = guiGetScreenSize()
local subject = false
local enabled = false
local distance = 20
local start = {0, -distance, 0}
local rotZ = 0
local rotX = 0

-- function onMouseMove(_, _, aX, aY)
-- end

local speed = 0.005

function orbitCamera(dt)
    local vehicle = subject
    if vehicle and isElement(vehicle) then
        if rotZ ~= 0 then
            local los = rotateUVW({{start[1], start[2], start[3], 0}}, 0, 0, 1, rotZ)
            start = {los[1][1], los[1][2], los[1][3]}        
            rotZ = 0
        end
        if rotX ~= 0 then
            local los = rotateUVW({{start[1], start[2], start[3], 0}}, 1, 0, 0, rotX)
            start = {los[1][1], los[1][2], los[1][3]}
            rotX = 0
        end

        if getKeyState("arrow_l") then
            rotZ = speed
            iprint("num_4")
        end
        if getKeyState("arrow_r") then
            rotZ = -speed
        end
        if getKeyState("arrow_u") then
            rotX = speed
        end
        if getKeyState("arrow_d") then
            rotX = -speed
        end
        
        local x, y, z = getPositionFromElementOffset(vehicle, start[1], start[2], start[3])
        local vx, vy, vz = getElementPosition(vehicle)
        setCameraMatrix(x, y, z, vx, vy, vz)
    end
end

-- Export
function setOrbitCameraTarget(vehicle)
    if not enabled and vehicle and getElementType(vehicle) == "vehicle" then
        enabled = true
        subject = vehicle
        addEventHandler("onClientPreRender", root, orbitCamera)
    elseif enabled then
        removeEventHandler("onClientPreRender", root, orbitCamera)
        enabled = false
        subject = false
        setCameraTarget(localPlayer)
    end
end

-- -- Command
-- function main(cmd, player)
--     if enabled then
--         --removeEventHandler("onClientCursorMove", root, onMouseMove)
--         removeEventHandler("onClientPreRender", root, orbitCamera)
--         outputChatBox("Orbit camera disabled", 255, 0, 0, false)
--         enabled = false
--         subject = false
--         setCameraTarget(localPlayer)
--         return
--     end

--     local p = getPlayerFromPartialName(player)
--     if not p then return outputChatBox("Error player does not exist") end
    
--     local vehicle = getPedOccupiedVehicle(p)
--     if vehicle then
--         --addEventHandler("onClientCursorMove", root, onMouseMove)
--         addEventHandler("onClientPreRender", root, orbitCamera)
--         outputChatBox("Orbit camera enabled", 0, 255, 0, false)
--         enabled = true
--         subject = vehicle
--     else
--         outputChatBox("Player not inside vehicle", 255, 0, 0, false)
--     end
-- end
-- addCommandHandler("orbitcam", main)