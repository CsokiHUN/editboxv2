sx, sy = guiGetScreenSize()

--
--Configs
--
BG_COLOR = tocolor(0, 0, 0, 180)
BG_HOVER_COLOR = tocolor(50, 50, 50, 180)
TEXT_COLOR = tocolor(255, 255, 255)
TEXT_CURSOR_COLOR = {255, 255, 255, 255}
PADDING = 5

--
--Fonts
--
local createdFonts = {}

function initFont(name, size)
    local tableKey = name..size
    if not createdFonts[tableKey] then 
        local font = dxCreateFont("assets/"..name..".ttf", size)
        createdFonts[tableKey] = font
    end
    return createdFonts[tableKey]
end

--
--Editbox
--
local createdBoxes = {}
local hoveredBox = false
local activeEditBox = false
local textCursor = {
    alpha = 0,
    targetAlpha = 255,
    tick = getTickCount()
}

local Box = {
    render = function(self)
        local currentText = guiGetText(self.gui)
        if self.typ and self.typ == "password" then 
            currentText = string.rep("*", string.len(currentText))
        end

        local x, y, w, h = self.x, self.y, self.w, self.h
        local textFont = initFont("regular", h * 0.4)
        dxDrawRectangle(x, y, w, h, self.hover(self) and BG_HOVER_COLOR or BG_COLOR)

        local textWidth = dxGetTextWidth(currentText, 1, textFont, false)
        local verticalAlign = "left"
        if textWidth >= (w - PADDING) then 
            verticalAlign = "right"
        end

        dxDrawText(currentText, x + PADDING, y, x + w - (PADDING * 2), y + h, TEXT_COLOR, 1, textFont, verticalAlign, "center", true)
        
        if activeEditBox == self.name then 
            guiEditSetCaretIndex(self.gui, string.len(currentText))

            local cursorColor = TEXT_CURSOR_COLOR
            cursorColor[4] = textCursor.alpha
            dxDrawText("|", math.min(x + PADDING + textWidth, x + w - (PADDING * 2)), y, x + w, y + h, tocolor(unpack(cursorColor)), 1, textFont, "left", "center")
        end
    end,
    
    hover = function(self)
        return isInSlot(self.x, self.y, self.w, self.h)
    end,

    getGUI = function(self)
        return self.gui
    end,

    setType = function(self, typ)
        self.typ = typ
    end,
    getType = function(self)
        return self.type
    end,

    setText = function(self, text)
        return guiSetText(self.gui, text)
    end,
    getText = function(self)
        return guiGetText(self.gui)
    end,
}

function createEditBox(name, x, y, w, h, text)
    text = text or ""

    destroyEditBox(name)

    local gui = guiCreateEdit(-1000, -1000, 0, 0, text, false, false)

    createdBoxes[name] = setmetatable({
        name = name,
        x = x,
        y = y,
        w = w,
        h = h,
        gui = gui
    }, { __index = Box})

    return createdBoxes[name]
end

function destroyEditBox(name)
    if createdBoxes[name] then 
        local box = createdBoxes[name]
        if isElement(box.gui) then 
            destroyElement(box.gui)
        end
        if hoveredBox == box then 
            hoveredBox = false
        end
        createdBoxes[name] = nil
    end
    if activeEditBox == name then 
        activeEditBox = false
    end
end

function getEditbox(name)
    return createdBoxes[name] or false
end

--
--Drawing
--
addEventHandler("onClientRender", root, function()
    hoveredBox = false

    for name, box in pairs(createdBoxes) do 
        if box:hover() then 
            hoveredBox = box
        end

        box:render()
    end

    local alpha = interpolateBetween(textCursor.alpha, 0, 0, textCursor.targetAlpha, 0, 0, (getTickCount()-textCursor.tick) / 500, "Linear")   
    textCursor.alpha = alpha
    if alpha == textCursor.targetAlpha then 
        textCursor.targetAlpha = alpha == 0 and 255 or 0
        textCursor.tick = getTickCount()
    end
end)

--
--Click
--
addEventHandler("onClientClick", root, function(button, state)
    if button == "left" and state == "down" then 
        if hoveredBox then 
            guiBringToFront(hoveredBox.gui)
            activeEditBox = hoveredBox.name
        else 
            activeEditBox = false
        end
    end
end)

--
--Test
--
local username = createEditBox("username", sx/2, sy/2 - 200, 150, 30, "username")
local passwd = createEditBox("passwd", sx/2, sy/2, 150, 30, "jelszó")
