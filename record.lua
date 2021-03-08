local maxTime = 5 * 60 * 1000 -- 5 minutes in milliseconds

--
local recordName = false
local isRecording = false
local tickStarted = false
local rootNode = false
local subject = false   -- The element(s) that are being recorded

-- Get the data from the current frame
function getFrameData(vehicle)
    --local left, forward, up, pos = unpack(getElementMatrix(vehicle))
    
    local adjustable = getVehicleAdjustableProperty(vehicle) or 0
    local gearDown = getVehicleLandingGearDown(vehicle) or false
    local position = {getElementPosition(vehicle)}
    local rotation = {getElementRotation(vehicle)}
    local velocity = {getElementVelocity(vehicle)}
    local components = {}

    for name, _ in pairs(getVehicleComponents(vehicle)) do
        local px, py, pz = getVehicleComponentPosition(vehicle, name)
        local rx, ry, rz = getVehicleComponentRotation(vehicle, name)
        components[name] = {px, py, pz, rx, ry, rz}    -- assumption: scale is always 1
    end

    return adjustable, gearDown, position, velocity, rotation, components
end

function addFrameData(rootNode, i, vehicle, tick)
    if rootNode and isElement(vehicle) and getElementType(vehicle) == "vehicle" and not isVehicleBlown(vehicle) then
        local modelID = getElementModel(vehicle)
        local adjustable, gearDown, pos, vel, rot, coms = getFrameData(vehicle)
        local px, py, pz = unpack(pos)
        local vx, vy, vz = unpack(vel)
        local rx, ry, rz = unpack(rot)
        local line = toCSV(tick, i, modelID, adjustable, gearDown, px, py, pz, vx, vy, vz, rx, ry, rz)

        -- Add the components
        for name, v in pairs(coms) do
            line = line..","..name..","..toCSV(unpack(v))
        end
        return fileWrite(rootNode, line.."\n")
    end
end

function startRecording(name)
    local filename = folder.."/"..name..ext
    if not fileExists(filename) then
        return fileCreate(filename)
    end
end

function stopRecording(rootNode, name)
    if rootNode then
        fileFlush(rootNode)
        fileClose(rootNode)
        save(name)
    end
end

function reloadRecording(rootNode, name)
    stopRecording(rootNode)
    local fh = startRecording(name)
    if fh then
        fileSetPos(fh, fileGetSize(fh))
        return fh
    end
end

-- Take an optional arg playName for recording a secondary vehicle
addCommandHandler("record", 
function (cmd, name, playerName)
    local player = false
    if playerName then
        player = getPlayerFromPartialName(playerName)
        outputDebugString("Found player")
    end

    if name and #name > 0 then
        local newRootNode = startRecording(name)
        if newRootNode then
            local vehicle = getPedOccupiedVehicle(localPlayer)
            local secondVehicle = nil
            if player then
                secondVehicle = getPedOccupiedVehicle(player) or nil
            end

            if vehicle then
                outputChatBox("Started recording...")
                
                isRecording = true
                recordName = name
                tickStarted = getTickCount()
                rootNode = newRootNode
                subject = {vehicle, secondVehicle}
                addEventHandler("onClientPreRender", root, doRecording)
                addEventHandler("onClientRender", root, drawIndicator)

            else
                outputChatBox("You must be inside a vehicle to start")
            end
        else
            outputChatBox("file exists")
        end
    elseif isRecording then
        stopRecording(rootNode, recordName)
        isRecording = false
        recordName = false
        tickStarted = false
        rootNode = false
        subject = false
        outputChatBox("stopped")
        removeEventHandler("onClientPreRender", root, doRecording)
        removeEventHandler("onClientRender", root, drawIndicator)
    else
        outputChatBox("/record [name] ([player])")
    end
end)

local lastTick = 0
local delay = 1000 
function doRecording()
    if isRecording and recordName and tickStarted and rootNode and subject and getTickCount() - tickStarted <= maxTime then
        -- if currentTick - tickStarted > delay then
        --     rootNode = reloadRecording(rootNode, recordName)
        -- end
        for i, v in ipairs(subject) do
            addFrameData(rootNode, i, v, getTickCount() - tickStarted - lastTick)
        end
        --outputChatBox(currentTick-tickStarted)
        lastTick = getTickCount() - tickStarted
    end
end

local screenW, screenH = guiGetScreenSize()
function drawIndicator()
    if isRecording then
        dxDrawCircle(screenW-20, 20, 6, _, _, tocolor(0, 0, 0))
        dxDrawCircle(screenW-20, 20, 5, _, _, tocolor(255, 0, 0))
    end
end
