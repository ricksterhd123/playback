local meta = "records.xml"


function toCSV(...) 
    local line = tostring(arg[1])
    for i = 2, #arg do
        line = line..","..tostring(arg[i])
    end
    return line
end

function fromCSV(line)
    return split(line, ",")
end 

function save(name)
    local rn = false
    if not fileExists(meta) then
        rn = xmlCreateFile(meta, "records")
    else
        rn = xmlLoadFile(meta)
    end
    local child = xmlCreateChild(rn, "record")
    if child then
        xmlNodeSetAttribute(child, "name", name)
        xmlSaveFile(rn)
        outputDebugString("Saved "..name.." to the meta record")
        return xmlUnloadFile(rn)
    end
    return false
end

function getRecordNames()
    if not fileExists(meta) then
        return {}
    else
        local names = {}
        local rn = xmlLoadFile(meta)
        local children = xmlNodeGetChildren(rn)
        if children then
            for i, v in ipairs(children) do
                names[#names+1] = xmlNodeGetAttribute(v, "name")
            end
        end
        return names
    end
end

function delete(name)
    local filename = folder.."/"..name..ext
    if not fileExists(filename) then
        outputDebugString("This file does not exist...")
        return false
    else
        if fileDelete(filename) then 
            local rn = xmlLoadFile(meta)
            local children = xmlNodeGetChildren(rn)
            if children then
                for _, v in ipairs(children) do
                    if name == xmlNodeGetAttribute(v, "name") then
                        xmlDestroyNode(v)
                        break
                    end
                end
            end
            xmlSaveFile(rn)
            xmlUnloadFile(rn)
            outputDebugString("Deleted file "..filename.." successfully")
        end
    end
end