local screenW, screenH = guiGetScreenSize()

local width, height = 400, 500
local gui = {}

function gui:createGUI(width, height, names)
    self.wnd = guiCreateWindow(screenW-width-10, screenH/2-height/2, width, height, "Recordings", false)
    self.playbtn = guiCreateButton(0, height-40, 110, 40, "play", false, self.wnd)
    self.deletebtn = guiCreateButton(130, height-40, 110, 40, "delete", false, self.wnd)
    self.closebtn  = guiCreateButton(250, height-40, 110, 40, "close", false, self.wnd)
    addEventHandler("onClientGUIClick", self.playbtn, function()
        gui:onPlay()
    end)
    addEventHandler("onClientGUIClick", self.deletebtn, function()
        gui:onDelete()
    end)
    addEventHandler("onClientGUIClick", self.closebtn, function ()
        gui:onClose()
    end)
    self.gridlist = guiCreateGridList(5, 20, width-5, height-75, false, self.wnd)
    
    guiGridListAddColumn(self.gridlist, "Saved recordings", 0.9)
    for i, v in ipairs(names) do
        guiGridListAddRow(self.gridlist, v)
    end
    if not isCursorShowing() then showCursor(true) end
end

function gui:updateGridList(names)
    guiGridListClear(self.gridlist)
    for i, v in ipairs(names) do
        guiGridListAddRow(self.gridlist, v)
    end
end

function gui:onDelete()
    local row, col = guiGridListGetSelectedItem(self.gridlist)
    local name = guiGridListGetItemText(self.gridlist, row, col)
    if not name then return false end
    delete(name)
    self:updateGridList(getRecordNames())
end

function gui:onPlay()
    local row, col = guiGridListGetSelectedItem(self.gridlist)
    local name = guiGridListGetItemText(self.gridlist, row, col)
    if not name then return false end
    startPlaying(name)
end

function gui:onClose()
    destroyElement(gui.wnd)
    gui.wnd = false
    showCursor(false)
end

addCommandHandler("records", 
function()
    if gui.wnd then
        destroyElement(gui.wnd)
        gui.wnd = false
        showCursor(false)
    else
        gui:createGUI(width, height, getRecordNames())
    end
end)
