function isInSlot(x, y, w, h)
    if not isCursorShowing() then 
        return false
    end

    local cursorX, cursorY = getCursorPosition()
    cursorX, cursorY = cursorX * sx, cursorY * sy

    return (cursorX >= x and cursorX <= (x + w)) and (cursorY >= y and cursorY <= (y + h))
end