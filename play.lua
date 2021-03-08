local isPlaying = false
local subject = false
local camUsed = false

local data = {}

function loadRecording(name)
    local filename = folder.."/"..name..ext
    if fileExists(filename) then
        local data = {}
        local fh = fileOpen(filename)
        local contents = split(fileRead(fh, fileGetSize(fh)), "\n")
        for i, v in ipairs(contents) do
            data[i] = fromCSV(v)
        end
        fileClose(fh)
        return data
    end
    return false
end

local curTime = 0
local lastTick = 0

function doPlayBack(dt)
    local curTick = getTickCount()
    local timeElapsed = curTick - lastTick
    if #data > 0 and subject then
        if timeElapsed >= tonumber(data[1][1]) then
            local i = tonumber(data[1][2])
            local modelID = tonumber(data[1][3])
            local adjustable = tonumber(data[1][4])
            local gearDown = data[1][5] == "true"
            
            local px = tonumber(data[1][6])
            local py = tonumber(data[1][7])
            local pz = tonumber(data[1][8])

            local vx = tonumber(data[1][9])
            local vy = tonumber(data[1][10])
            local vz = tonumber(data[1][11])

            local rx = tonumber(data[1][12])
            local ry = tonumber(data[1][13])
            local rz = tonumber(data[1][14])

            if not subject[i] then
                subject[i] = createVehicle(modelID, px, py, pz)
            end

            setVehicleAdjustableProperty(subject[i], adjustable)
            if getVehicleLandingGearDown(subject[i]) ~= gearDown then
                setVehicleLandingGearDown(subject[i], gearDown)
            end

            setElementVelocity(subject[i], vx, vy, vz)
            setElementRotation(subject[i], rx, ry, rz)
            setElementPosition(subject[i], px+vx, py+vy, pz+vz)
            local j = 15
            while j + 6 < #data[1] do
                local name = data[1][j]
                local set1 = setVehicleComponentPosition(subject[i], name, tonumber(data[1][j+1]), tonumber(data[1][j+2]), tonumber(data[1][j+3]))
                local set2 = setVehicleComponentRotation(subject[i], name, tonumber(data[1][j+4]), tonumber(data[1][j+5]), tonumber(data[1][j+6]))
                j = j + 7
            end
            table.remove(data, 1)
            lastTick = curTick
        end
    end
end


function startPlaying(name, cam)
    data = loadRecording(name)
    if data then
        isPlaying = name
        if cam == "free" then
            camUsed = cam
            -- Set the freecam position to the first vehicle position
            setFreecamEnabled(data[1][6], data[1][7], data[1][8])
        end
        subject = {}
        -- To be implemented
        -- elseif cam == "orbit" then
        --     camUsed = cam
        --     setOrbitCameraTarget(subject)
        -- end

        addEventHandler("onClientPreRender", root, doPlayBack)
        return true
    else
        return false
    end
end

function stopPlaying()
    isPlaying = false
        
    for i, v in ipairs(subject) do
        destroyElement(v)
    end

    subject = false

    if camUsed == "free" then
        setFreecamDisabled()
        camUsed = false
    elseif camUsed == "orbit" then
        setOrbitCameraTarget(false)
        camUsed = false
    end

    data = {}
    setFreecamDisabled()
    removeEventHandler("onClientPreRender", root, doPlayBack)
end

function main(_, name, cam)
    if isPlaying then
        stopPlaying()
    elseif name and #name > 0 then
        if not startPlaying(name, cam) then
            outputChatBox("File not found...")
        end
    else
        outputChatBox("/playback [name] [cam]")
    end
end
addCommandHandler("playback", main)
