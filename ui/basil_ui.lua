local ui = {}
ui.text = {}
ui.draw = {}
ui.widgets = {}
ui.layout = {}

ui.dirty = true
ui.target = term

--------------------------------------------------
-- Theme
--------------------------------------------------

ui.theme = {}
ui.theme.colors = {
    background = colors.black,
    foreground = colors.white
}
ui.theme.colors.defaults = {
    background = colors.black,
    foreground = colors.white,

    buttonBackground = colors.gray,
    buttonForeground = colors.white,
    buttonSelectedBackground = colors.white,
    buttonSelectedForeground = colors.black
}
ui.theme.colors.button = {
    background = colors.gray,
    foreground = colors.white,

    selectedBackground = colors.white,
    selectedForeground = colors.black
}
ui.theme.characters = {
    horizontal = "-",
    vertical = "|",

    topLeft = "+",
    topRight = "+",
    bottomLeft = "+",
    bottomRight = "+",

    leftJunction = "+",
    rightJunction = "+",

    progressEmpty = "-",
    progressFill = "#"
}

--------------------------------------------------
-- Terminal
--------------------------------------------------

function ui.invalidate()
    ui.dirty = true
end

function ui.validate()
    ui.dirty = false
end

function ui.isDirty()
    return ui.dirty
end

function ui.clear()
    ui.target.clear()
    ui.target.setCursorPos(1, 1)
end

function ui.setStyle(style)
    for k, v in pairs(style) do
        if k == "background" then
            ui.theme.colors.background = v
        elseif k == "foreground" then
            ui.theme.colors.foreground = v
        end
    end
end

function ui.resetStyle()
    ui.theme.colors.background = ui.theme.colors.defaults.background
    ui.theme.colors.foreground = ui.theme.colors.defaults.foreground

    ui.theme.colors.button.background = ui.theme.colors.defaults.buttonBackground
    ui.theme.colors.button.foreground = ui.theme.colors.defaults.buttonForeground
    ui.theme.colors.button.selectedBackground = ui.theme.colors.defaults.buttonSelectedBackground
    ui.theme.colors.button.selectedForeground = ui.theme.colors.defaults.buttonSelectedForeground

    ui.target.setBackgroundColor(ui.theme.colors.background)
    ui.target.setTextColor(ui.theme.colors.foreground)
end

function ui.setTarget(target)
    ui.target = target
end

function ui.setTextScale(scale)
    if ui.target.setTextScale then
        ui.target.setTextScale(scale)
    end
end

--------------------------------------------------
-- Text
--------------------------------------------------

function ui.text.center(y, text)
    local w, _ = ui.target.getSize()

    local x = math.floor((w - #text) / 2) + 1

    ui.draw.text(x, y, text)
end

--------------------------------------------------
-- Draw
--------------------------------------------------

function ui.draw.point(x, y, char)
    ui.target.setCursorPos(x, y)
    ui.target.write(char)
end

function ui.draw.hLine(x, y, length)
    ui.target.setCursorPos(x, y)
    ui.target.write(string.rep(ui.theme.characters.horizontal, length))
end

function ui.draw.vLine(x, y, length)
    for i = 1, length - 1 do
        ui.target.setCursorPos(x, y + i)
        ui.target.write(ui.theme.characters.vertical)
    end
end

function ui.draw.box(x, y, w, h)
    ui.draw.hLine(x + 1, y, w - 2)
    ui.draw.hLine(x + 1, y + h - 1, w - 2)

    ui.draw.vLine(x, y, h - 1)
    ui.draw.vLine(x + w - 1, y, h - 1)

    ui.draw.point(x, y, ui.theme.characters.topLeft)
    ui.draw.point(x + w - 1, y, ui.theme.characters.topRight)
    ui.draw.point(x, y + h - 1, ui.theme.characters.bottomLeft)
    ui.draw.point(x + w - 1, y + h - 1, ui.theme.characters.bottomRight)
end

function ui.draw.fill(x, y, w, h)
    local blank = string.rep(" ", w)

    for i = 0, h - 1 do
        ui.target.setCursorPos(x, y + i)
        ui.target.write(blank)
    end
end

function ui.draw.text(x, y, text)
    ui.target.setCursorPos(x, y)
    ui.target.write(text)
end

--------------------------------------------------
-- Widgets
--------------------------------------------------

function ui.widgets.text(rect, text, hAlign, vAlign)
    hAlign = hAlign or "left"
    vAlign = vAlign or "top"

    local x, y = rect.x, rect.y

    if hAlign == "center" then
        x = rect.x + math.floor((rect.w - #text) / 2)
    elseif hAlign == "right" then
        x = rect.x + (rect.w - #text)
    end

    if vAlign == "middle" then
        y = rect.y + math.floor(rect.h / 2)
    elseif vAlign == "bottom" then
        y = rect.y + rect.h - 1
    end

    local available = rect.w - (x - rect.x)
    if #text > available then
        text = text:sub(1, available)
    end

    ui.draw.text(x, y, text)
end

function ui.widgets.list(rect, lst, drawItem, spacing)
    spacing = spacing or 0
    drawItem = drawItem or function(row, item)
        ui.widgets.text(row, tostring(item))
    end

    local remaining = ui.layout.copy(rect)

    for _, item in ipairs(lst) do
        if remaining.h <= 0 then
            break
        end

        local row = ui.layout.row(remaining, 1)
        drawItem(row, item)

        remaining = ui.layout.consumeTop(remaining, 1)
    end

    return remaining
end

function ui.widgets.panel(rect, title, hAlign)
    ui.draw.box(rect.x, rect.y, rect.w, rect.h)
    ui.draw.fill(rect.x + 1, rect.y + 1, rect.w - 2, rect.h - 2)

    if title == nil then
        return rect
    end

    local titleRect = ui.layout.margin(rect, 1, 1, 1, rect.h - 2)
    ui.widgets.text(titleRect, title, hAlign)

    ui.draw.hLine(rect.x + 1, rect.y + 2, rect.w - 2)
    ui.draw.point(rect.x, rect.y + 2, ui.theme.characters.leftJunction)
    ui.draw.point(rect.x + rect.w - 1, rect.y + 2, ui.theme.characters.rightJunction)

    return ui.layout.margin(rect, 1, 3, 1, 1)
end

function ui.widgets.progress(rect, amount)
    -- TODO: Allow amount to be any value and have a min & max variable rather than forcing 0.0-1.0
    
    amount = math.max(0, math.min(1, amount))
    local percentage = amount

    local filled = math.floor(rect.w * percentage)
    local empty = rect.w - filled

    ui.draw.text(rect.x, rect.y, string.rep(ui.theme.characters.progressFill, filled) .. string.rep(ui.theme.characters.progressEmpty, empty))
end

function ui.widgets.button(rect, text, selected, bordered)
    local bg = ui.theme.colors.button.background
    local fg = ui.theme.colors.button.foreground
    
    if selected then
        bg = ui.theme.colors.button.selectedBackground
        fg = ui.theme.colors.button.selectedForeground
    end

    ui.target.setBackgroundColor(bg)
    ui.target.setTextColor(fg)

    if bordered then
        ui.draw.box(rect.x, rect.y, rect.w, rect.h)
        ui.draw.fill(rect.x + 1, rect.y + 1, rect.w - 2, rect.h - 2)
    else
        ui.draw.fill(rect.x, rect.y, rect.w, rect.h)
    end
    ui.widgets.text(rect, text, "center", "middle")

    ui.target.setBackgroundColor(ui.theme.colors.background)
    ui.target.setTextColor(ui.theme.colors.foreground)
end

--------------------------------------------------
-- Layout
--------------------------------------------------

function ui.layout.copy(rect)
    return {
        x = rect.x,
        y = rect.y,
        w = rect.w,
        h = rect.h
    }
end

function ui.layout.row(rect, index)
    return {
        x = rect.x,
        y = rect.y + index - 1,
        w = rect.w,
        h = 1
    }
end

function ui.layout.takeLeft(rect, width)
    return {
        x = rect.x,
        y = rect.y,
        w = width,
        h = rect.h
    }
end

function ui.layout.takeRight(rect, width)
    return {
        x = rect.x + rect.w - width,
        y = rect.y,
        w = width,
        h = rect.h
    }
end

function ui.layout.takeTop(rect, height)
    return {
        x = rect.x,
        y = rect.y,
        w = rect.w,
        h = height
    }
end

function ui.layout.takeBottom(rect, height)
    return {
        x = rect.x,
        y = rect.y + rect.h - height,
        w = rect.w,
        h = rect.h
    }
end

function ui.layout.consumeLeft(rect, width)
    return {
        x = rect.x + width,
        y = rect.y,
        w = rect.w - width,
        h = rect.h
    }
end

function ui.layout.consumeRight(rect, width)
    return {
        x = rect.x,
        y = rect.y,
        w = rect.w - width,
        h = rect.h
    }
end

function ui.layout.consumeTop(rect, height)
    return {
        x = rect.x,
        y = rect.y + height,
        w = rect.w,
        h = rect.h - height
    }
end

function ui.layout.consumeBottom(rect, height)
    return {
        x = rect.x,
        y = rect.y,
        w = rect.w,
        h = rect.h - height
    }
end

function ui.layout.center(rect, w, h)
    return {
        x = rect.x + math.floor((rect.w - w) / 2),
        y = rect.y + math.floor((rect.h - h) / 2),
        w = w,
        h = h
    }
end

function ui.layout.centerX(rect, w)
    return {
        x = rect.x + math.floor((rect.w - w) / 2),
        y = rect.y,
        w = w,
        h = rect.h
    }
end

function ui.layout.centerY(rect, h)
    return {
        x = rect.x,
        y = rect.y + math.floor((rect.h - h) / 2),
        w = rect.w,
        h = h
    }
end

function ui.layout.full()
    local terminalWidth, terminalHeight = ui.target.getSize()
    return {
        x = 1,
        y = 1,
        w = terminalWidth,
        h = terminalHeight
    }
end

function ui.layout.splitVertical(rect, split_percentage)
    local left = {
        x = rect.x,
        y = rect.y,
        w = math.floor(rect.w * split_percentage),
        h = rect.h
    }
    local right = {
        x = rect.x + left.w,
        y = rect.y,
        w = rect.w - left.w,
        h = rect.h
    }

    return left, right
end

function ui.layout.columns(rect, split_ratios)
    local columns = {}

    local currentX = rect.x
    local remainingWidth = rect.w

    for i, ratio in ipairs(split_ratios) do
        local width

        if i == #split_ratios then
            width = remainingWidth
        else
            width = math.floor(rect.w * ratio)
        end

        table.insert(columns, {
            x = currentX,
            y = rect.y,
            w = width,
            h = rect.h
        })

        currentX = currentX + width
        remainingWidth = remainingWidth - width
    end

    return columns
end

function ui.layout.splitHorizontal(rect, split_percentage)
    local top = {
        x = rect.x,
        y = rect.y,
        w = rect.w,
        h = math.floor(rect.h * split_percentage)
    }
    local bottom = {
        x = rect.x,
        y = rect.y + top.h,
        w = rect.w,
        h = rect.h - top.h
    }

    return top, bottom
end

function ui.layout.inset(rect, amount)
    return {
        x = rect.x + amount,
        y = rect.y + amount,
        w = rect.w - amount * 2,
        h = rect.h - amount * 2
    }
end

function ui.layout.margin(rect, left, top, right, bottom)
    left = left or 0
    top = top or left
    right = right or left
    bottom = bottom or top

    return {
        x = rect.x + left,
        y = rect.y + top,
        w = rect.w - left - right,
        h = rect.h - top - bottom
    }
end

function ui.layout.verticalStack(rect, w, elementHeight, elementCount, spacing)
    spacing = spacing or 0

    local rects = {}

    local totalHeight =
        elementCount * elementHeight +
        (elementCount - 1) * spacing

    local startY = rect.y + math.floor((rect.h - totalHeight) / 2)

    for i = 1, elementCount do
        table.insert(rects, {
            x = rect.x + math.floor((rect.w - w) / 2),
            y = startY + (i - 1) * (elementHeight + spacing),
            w = w,
            h = elementHeight
        })
    end

    return rects
end

return ui