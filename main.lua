--[[
    Menu + Settings + Sandwich Easter Egg
    by SOLD
    Исправленная версия v3: Фикс прозрачности + Текст разработки
--]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- Настройки
-- ВАЖНО: Здесь transparency означает степень прозрачности (0=видимо, 100=невидимо).
-- 85 означает, что меню будет на 85% прозрачным (хорошо видно игру).
local menuColor = Color3.fromRGB(20, 20, 25)
local menuTransparency = 85 
local currentLanguage = "RU"
local sandwichClicks = 0
local lastClickTime = 0
local isDragging = false
local dragObject = nil
local dragStart = nil
local dragStartPos = nil
local animationConnection = nil
local sliderConnection = nil
local sliderEndedConnection = nil
local creatorButtonRef = nil

local T = {
    RU = {
        title = "MENU", settings = "Настройки",
        color = "Цвет меню", transparency = "Прозрачность",
        language = "Язык", save = "Сохранить",
        saved = "✅ Сохранено!", close = "Закрыть", back = "Назад",
        colors = {"Тёмный","Красный","Зелёный","Синий","Фиолетовый","Оранжевый","Белый"},
        devText = "Идёт разработка читов / эксплойтов"
    },
    EN = {
        title = "MENU", settings = "Settings",
        color = "Menu Color", transparency = "Transparency",
        language = "Language", save = "Save",
        saved = "✅ Saved!", close = "Close", back = "Back",
        colors = {"Dark","Red","Green","Blue","Purple","Orange","White"},
        devText = "Cheats/Exploits Development in Progress"
    }
}

local COLORS = {
    Color3.fromRGB(20, 20, 25), Color3.fromRGB(40, 5, 5), Color3.fromRGB(5, 30, 5),
    Color3.fromRGB(5, 5, 40), Color3.fromRGB(40, 5, 40), Color3.fromRGB(40, 20, 5), Color3.fromRGB(40, 40, 40)
}

local guiExists = false

-- Сохранение
local function saveSettings()
    local data = string.format("lang=%s;trans=%d;color=%d,%d,%d",
        currentLanguage, menuTransparency,
        math.floor(menuColor.R*255), math.floor(menuColor.G*255), math.floor(menuColor.B*255))
    pcall(function() writefile("Menu_Settings.txt", data) end)
    
    local existing = game.CoreGui:FindFirstChild("SaveNotification")
    if existing then existing:Destroy() end
    
    local sg = Instance.new("ScreenGui", game.CoreGui)
    sg.Name = "SaveNotification"
    local c = Instance.new("Frame", sg)
    c.Size = UDim2.new(0, 150, 0, 30)
    c.Position = UDim2.new(1.2, 0, 0.9, -15)
    c.BackgroundColor3 = Color3.new(0,0,0)
    c.BackgroundTransparency = 0.3
    c.BorderSizePixel = 0
    Instance.new("UICorner", c).CornerRadius = UDim.new(0, 8)
    local l = Instance.new("TextLabel", c)
    l.Size = UDim2.new(1, 0, 1, 0)
    l.BackgroundTransparency = 1
    l.TextColor3 = Color3.new(1,1,1)
    l.Font = Enum.Font.GothamBold
    l.TextSize = 12
    l.Text = T[currentLanguage].saved
    TweenService:Create(c, TweenInfo.new(0.4), {Position = UDim2.new(1, -160, 0.9, -15)}):Play()
    task.delay(2, function()
        if sg.Parent then
            TweenService:Create(c, TweenInfo.new(0.3), {Position = UDim2.new(1.2, 0, 0.9, -15)}):Play()
            task.delay(0.3, function() sg:Destroy() end)
        end
    end)
end

local function loadSettings()
    local success, content = pcall(function() 
        if isfile and isfile("Menu_Settings.txt") then
            return readfile("Menu_Settings.txt") 
        end
        return nil
    end)
    
    if not success or not content or content == "" then return end
    
    for k, v in string.gmatch(content, "([^=;]+)=([^;]+)") do
        k = string.gsub(k, "^%s*(.-)%s*$", "%1")
        v = string.gsub(v, "^%s*(.-)%s*$", "%1")
        
        if k == "lang" then 
            currentLanguage = (v == "RU") and "RU" or "EN"
        elseif k == "trans" then 
            local transNum = tonumber(v)
            if transNum then
                -- Ограничиваем от 0 до 100
                menuTransparency = math.clamp(transNum, 0, 100)
            end
        elseif k == "color" then
            local r,g,b = string.match(v, "(%d+),(%d+),(%d+)")
            if r and g and b then 
                local rNum, gNum, bNum = tonumber(r), tonumber(g), tonumber(b)
                if rNum and gNum and bNum then
                    menuColor = Color3.fromRGB(
                        math.clamp(rNum, 0, 255), 
                        math.clamp(gNum, 0, 255), 
                        math.clamp(bNum, 0, 255)
                    )
                end
            end
        end
    end
end

loadSettings()

-- ================= ПАСХАЛКА СЭНДВИЧ =================
local function showSandwich()
    local sg = Instance.new("ScreenGui", game.CoreGui)
    sg.Name = "SandwichEffect"
    
    local lab = Instance.new("TextLabel", sg)
    lab.Size = UDim2.new(0, 0, 0, 0)
    lab.Position = UDim2.new(0.5, 0, 0.5, 0)
    lab.BackgroundTransparency = 1
    lab.Text = "🥪"
    lab.Font = Enum.Font.GothamBlack
    lab.TextSize = 100
    lab.TextColor3 = Color3.new(1, 0.9, 0.5)
    
    TweenService:Create(lab, TweenInfo.new(0.8, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, 200, 0, 200),
        Position = UDim2.new(0.5, -100, 0.5, -100)
    }):Play()
    
    local msg = Instance.new("TextLabel", sg)
    msg.Size = UDim2.new(0, 300, 0, 40)
    msg.Position = UDim2.new(0.5, -150, 0.7, 0)
    msg.BackgroundTransparency = 1
    msg.Text = "🥪 SANDWICH ACTIVATED! 🥪"
    msg.TextColor3 = Color3.new(1, 1, 0)
    msg.Font = Enum.Font.GothamBlack
    msg.TextSize = 20
    msg.TextTransparency = 1
    
    TweenService:Create(msg, TweenInfo.new(0.5), {TextTransparency = 0}):Play()
    
    task.delay(2, function()
        if sg.Parent then
            TweenService:Create(lab, TweenInfo.new(0.3), {Size = UDim2.new(0,0,0,0), Position = UDim2.new(0.5,0,0.5,0)}):Play()
            TweenService:Create(msg, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
            task.delay(0.3, function() sg:Destroy() end)
        end
    end)
end

local function onSandwichClick()
    local now = tick()
    if now - lastClickTime > 2 then sandwichClicks = 0 end
    lastClickTime = now
    sandwichClicks = sandwichClicks + 1
    
    if creatorButtonRef and creatorButtonRef.Parent then
        creatorButtonRef.TextColor3 = Color3.fromHSV(sandwichClicks / 5, 1, 1)
    end
    
    if sandwichClicks >= 5 then
        sandwichClicks = 0
        showSandwich()
        if creatorButtonRef and creatorButtonRef.Parent then
            creatorButtonRef.TextColor3 = Color3.fromRGB(100,100,120)
        end
    end
end

-- ================= МЕНЮ =================
local function createMenu()
    if guiExists then return end
    if not game.CoreGui then return end
    
    guiExists = true
    
    local gui = Instance.new("ScreenGui", game.CoreGui)
    gui.Name = "Menu"
    gui.ResetOnSpawn = false

    local frame = Instance.new("Frame", gui)
    frame.Name = "MainFrame"
    frame.Size = UDim2.new(0, 0, 0, 0)
    frame.Position = UDim2.new(0.5, 0, 0.5, 0)
    frame.BackgroundColor3 = menuColor
    -- ИСПРАВЛЕНО: Делим на 100, чтобы получить правильное значение прозрачности (0-1)
    frame.BackgroundTransparency = menuTransparency / 100
    frame.BorderSizePixel = 0
    frame.ClipsDescendants = true
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)

    -- Текст разработки (Водяной знак внутри меню)
    local devLabel = Instance.new("TextLabel", frame)
    devLabel.Name = "DevLabel"
    devLabel.Size = UDim2.new(1, -20, 0, 20)
    devLabel.Position = UDim2.new(0, 10, 1, -25) -- Внизу меню
    devLabel.BackgroundTransparency = 1
    devLabel.Text = T[currentLanguage].devText
    devLabel.TextColor3 = Color3.fromRGB(255, 50, 50) -- Красный цвет для внимания
    devLabel.Font = Enum.Font.GothamBold
    devLabel.TextSize = 10
    devLabel.TextTransparency = 0.5 -- Полупрозрачный
    devLabel.ZIndex = 0 -- Чтобы был под кнопками, если они перекрывают

    -- Анимация появления
    pcall(function()
        TweenService:Create(frame, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 250, 0, 220),
            Position = UDim2.new(0, 20, 0, 20),
            BackgroundTransparency = menuTransparency / 100
        }):Play()
    end)

    -- Заголовок
    local header = Instance.new("Frame", frame)
    header.Name = "Header"
    header.Size = UDim2.new(1, 0, 0, 28)
    header.BackgroundColor3 = Color3.new(0,0,0)
    header.BackgroundTransparency = 0.5 -- Хедер всегда чуть темнее
    header.BorderSizePixel = 0
    Instance.new("UICorner", header).CornerRadius = UDim.new(0, 10)

    local title = Instance.new("TextLabel", header)
    title.Name = "Title"
    title.Size = UDim2.new(1, -55, 1, 0)
    title.Position = UDim2.new(0, 10, 0, 0)
    title.Text = T[currentLanguage].title
    title.TextColor3 = Color3.new(1,1,1)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBlack
    title.TextSize = 14
    title.TextXAlignment = Enum.TextXAlignment.Left

    local btnMin = Instance.new("TextButton", header)
    btnMin.Name = "MinimizeBtn"
    btnMin.Size = UDim2.new(0, 24, 1, 0)
    btnMin.Position = UDim2.new(1, -48, 0, 0)
    btnMin.Text = "‒"
    btnMin.BackgroundTransparency = 1
    btnMin.TextColor3 = Color3.new(1,1,1)
    btnMin.Font = Enum.Font.GothamBold
    btnMin.TextSize = 14

    local btnClose = Instance.new("TextButton", header)
    btnClose.Name = "CloseBtn"
    btnClose.Size = UDim2.new(0, 24, 1, 0)
    btnClose.Position = UDim2.new(1, -24, 0, 0)
    btnClose.Text = "✕"
    btnClose.BackgroundTransparency = 1
    btnClose.TextColor3 = Color3.new(1,0.3,0.3)
    btnClose.Font = Enum.Font.GothamBold
    btnClose.TextSize = 13

    -- Кружок
    local circle = Instance.new("TextButton", gui)
    circle.Name = "CircleBtn"
    circle.Size = UDim2.new(0, 0, 0, 0)
    circle.Position = frame.Position
    circle.BackgroundColor3 = Color3.new(0,0,0)
    circle.Text = "M"
    circle.TextColor3 = Color3.new(1,1,1)
    circle.Font = Enum.Font.GothamBlack
    circle.TextSize = 16
    circle.BorderSizePixel = 0
    circle.Visible = false
    Instance.new("UICorner", circle).CornerRadius = UDim.new(1,0)

    -- Анимация цвета кружка
    local hueC = 0
    animationConnection = RunService.RenderStepped:Connect(function()
        if circle.Visible and gui.Parent then
            hueC = (hueC + 0.008) % 1
            pcall(function() circle.TextColor3 = Color3.fromHSV(hueC, 0.9, 0.9) end)
        end
    end)

    -- Контент
    local content = Instance.new("ScrollingFrame", frame)
    content.Name = "Content"
    content.Size = UDim2.new(1, -16, 1, -60)
    content.Position = UDim2.new(0, 8, 0, 34)
    content.BackgroundTransparency = 1
    content.ScrollBarThickness = 3
    content.AutomaticCanvasSize = Enum.AutomaticSize.Y
    content.CanvasSize = UDim2.new(0, 0, 0, 0)
    Instance.new("UIListLayout", content).SortOrder = Enum.SortOrder.LayoutOrder
    Instance.new("UIPadding", content).PaddingLeft = UDim.new(0, 0)

    local function makeBtn(text, cb)
        local b = Instance.new("TextButton", content)
        b.Size = UDim2.new(1, 0, 0, 30)
        b.Text = text
        b.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
        b.BackgroundTransparency = 0.3
        b.TextColor3 = Color3.new(1,1,1)
        b.Font = Enum.Font.GothamBold
        b.TextSize = 13
        b.BorderSizePixel = 0
        Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
        
        b.MouseEnter:Connect(function()
            if b.Parent then pcall(function() TweenService:Create(b, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(70,70,90)}):Play() end) end
        end)
        b.MouseLeave:Connect(function()
            if b.Parent then pcall(function() TweenService:Create(b, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(50,50,60)}):Play() end) end
        end)
        b.MouseButton1Click:Connect(function()
            if b.Parent then
                pcall(function() TweenService:Create(b, TweenInfo.new(0.1), {Size = UDim2.new(1, -4, 0, 28)}):Play() end)
                task.delay(0.1, function()
                    if b.Parent then pcall(function() TweenService:Create(b, TweenInfo.new(0.15, Enum.EasingStyle.Back), {Size = UDim2.new(1, 0, 0, 30)}):Play() end) end
                end)
                if cb then pcall(cb) end
            end
        end)
        return b
    end

    local function createMainMenu()
        content:ClearAllChildren()
        makeBtn("⚙ " .. T[currentLanguage].settings, function()
            createSettingsMenu()
        end)
    end

    local function createSettingsMenu()
        content:ClearAllChildren()
        
        -- Цвет
        local colorIdx = 1
        for i, c in ipairs(COLORS) do if c == menuColor then colorIdx = i; break end end
        
        makeBtn("🎨 " .. T[currentLanguage].color .. ": " .. T[currentLanguage].colors[colorIdx], function()
            colorIdx = colorIdx % #COLORS + 1
            menuColor = COLORS[colorIdx]
            frame.BackgroundColor3 = menuColor
            saveSettings()
            createSettingsMenu()
        end)
        
        -- Язык
        makeBtn("🌐 " .. T[currentLanguage].language .. ": " .. currentLanguage, function()
            currentLanguage = (currentLanguage == "RU") and "EN" or "RU"
            saveSettings()
            updateAllTexts()
        end)
        
        -- Прозрачность
        local tf = Instance.new("Frame", content)
        tf.Size = UDim2.new(1, 0, 0, 30)
        tf.BackgroundTransparency = 1
        
        local tl = Instance.new("TextLabel", tf)
        tl.Size = UDim2.new(0, 90, 1, 0)
        tl.BackgroundTransparency = 1
        tl.TextColor3 = Color3.new(1,1,1)
        tl.Font = Enum.Font.Gotham
        tl.TextSize = 12
        tl.Text = "🔲 " .. T[currentLanguage].transparency
        
        local tk = Instance.new("Frame", tf)
        tk.Name = "SliderTrack"
        tk.Size = UDim2.new(1, -130, 0, 5)
        tk.Position = UDim2.new(0, 100, 0.5, -2)
        tk.BackgroundColor3 = Color3.fromRGB(50,50,50)
        tk.BorderSizePixel = 0
        Instance.new("UICorner", tk).CornerRadius = UDim.new(0, 2)
        
        local kn = Instance.new("TextButton", tk)
        kn.Name = "SliderKnob"
        kn.Size = UDim2.new(0, 14, 1, 0)
        kn.BackgroundColor3 = Color3.fromRGB(0,200,100)
        kn.Text = ""
        kn.AutoButtonColor = false
        Instance.new("UICorner", kn).CornerRadius = UDim.new(0, 7)
        -- ИСПРАВЛЕНО: Позиция слайдера теперь корректно отражает проценты (0-100)
        kn.Position = UDim2.new(menuTransparency/100, -7, 0, 0)
        
        local kd = false
        
        if sliderConnection then pcall(function() sliderConnection:Disconnect() end) end
        if sliderEndedConnection then pcall(function() sliderEndedConnection:Disconnect() end) end
        
        kn.InputBegan:Connect(function(input) 
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then kd = true end 
        end)
        
        sliderConnection = UserInputService.InputChanged:Connect(function(input)
            if kd and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                local success, rx = pcall(function()
                    return math.clamp((input.Position.X - tk.AbsolutePosition.X) / tk.AbsoluteSize.X, 0, 1)
                end)
                if success and rx then
                    menuTransparency = math.floor(rx * 100)
                    kn.Position = UDim2.new(rx, -7, 0, 0)
                    -- ИСПРАВЛЕНО: Обновляем прозрачность главного фрейма
                    frame.BackgroundTransparency = menuTransparency / 100
                end
            end
        end)
        
        sliderEndedConnection = UserInputService.InputEnded:Connect(function(input)
            if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
                kd = false
                saveSettings()
            end
        end)
        
        makeBtn("💾 " .. T[currentLanguage].save, function() saveSettings() end)
        makeBtn("← " .. T[currentLanguage].back, function() createMainMenu() end)
    end

    local function updateAllTexts()
        local titleObj = frame:FindFirstChild("Header") and frame.Header:FindFirstChild("Title")
        if titleObj then titleObj.Text = T[currentLanguage].title end
        
        -- Обновляем текст разработки
        local devLbl = frame:FindFirstChild("DevLabel")
        if devLbl then devLbl.Text = T[currentLanguage].devText end

        if content:FindFirstChildWhichIsA("TextButton") then
            local firstBtn = content:FindFirstChildWhichIsA("TextButton")
            if firstBtn and firstBtn.Text:find("⚙") then
                createMainMenu()
            else
                createSettingsMenu()
            end
        end
    end

    createMainMenu()

    -- Пасхалка
    local creatorBtn = Instance.new("TextButton", frame)
    creatorBtn.Name = "CreatorButton"
    creatorBtn.Size = UDim2.new(1, 0, 0, 16)
    creatorBtn.Position = UDim2.new(0, 0, 1, -18)
    creatorBtn.BackgroundTransparency = 1
    creatorBtn.TextColor3 = Color3.fromRGB(100,100,120)
    creatorBtn.Font = Enum.Font.Gotham
    creatorBtn.TextSize = 10
    creatorBtn.Text = "by SOLD"
    creatorBtn.AutoButtonColor = false
    creatorBtn.ZIndex = 10 -- Поверх текста разработки
    
    creatorButtonRef = creatorBtn
    creatorBtn.MouseButton1Click:Connect(onSandwichClick)

    -- Сворачивание
    btnMin.MouseButton1Click:Connect(function()
        pcall(function() TweenService:Create(frame, TweenInfo.new(0.3), {Size = UDim2.new(0,0,0,0), BackgroundTransparency = 1}):Play() end)
        task.delay(0.3, function()
            if frame.Parent then
                frame.Visible = false
                circle.Position = frame.Position
                circle.Visible = true
                pcall(function() TweenService:Create(circle, TweenInfo.new(0.4, Enum.EasingStyle.Back), {Size = UDim2.new(0,40,0,40)}):Play() end)
            end
        end)
    end)

    circle.MouseButton1Click:Connect(function()
        pcall(function() TweenService:Create(circle, TweenInfo.new(0.2), {Size = UDim2.new(0,0,0,0)}):Play() end)
        task.delay(0.2, function()
            if circle.Parent then
                circle.Visible = false
                frame.Position = circle.Position
                frame.Visible = true
                pcall(function()
                    TweenService:Create(frame, TweenInfo.new(0.4, Enum.EasingStyle.Back), {
                        Size = UDim2.new(0,250,0,220), 
                        BackgroundTransparency = menuTransparency / 100
                    }):Play()
                end)
            end
        end)
    end)

    -- Закрыть
    btnClose.MouseButton1Click:Connect(function()
        pcall(function() TweenService:Create(frame, TweenInfo.new(0.3), {Size = UDim2.new(0,0,0,0), BackgroundTransparency = 1}):Play() end)
        task.delay(0.3, function()
            if gui.Parent then
                if animationConnection then pcall(function() animationConnection:Disconnect() end); animationConnection = nil end
                if sliderConnection then pcall(function() sliderConnection:Disconnect() end); sliderConnection = nil end
                if sliderEndedConnection then pcall(function() sliderEndedConnection:Disconnect() end); sliderEndedConnection = nil end
                
                gui:Destroy()
                guiExists = false
                creatorButtonRef = nil
            end
        end)
    end)

    -- Перетаскивание
    local function startDrag(input, obj)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isDragging = true
            dragObject = obj
            dragStart = input.Position
            dragStartPos = obj.Position
        end
    end
    
    frame.InputBegan:Connect(function(input) startDrag(input, frame) end)
    circle.InputBegan:Connect(function(input) startDrag(input, circle) end)
    
    UserInputService.InputChanged:Connect(function(input)
        if isDragging and dragObject and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            pcall(function()
                dragObject.Position = UDim2.new(dragStartPos.X.Scale, dragStartPos.X.Offset + delta.X, dragStartPos.Y.Scale, dragStartPos.Y.Offset + delta.Y)
            end)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isDragging = false
            dragObject = nil
        end
    end)
end

pcall(function() createMenu() end)

if not guiExists then
    task.delay(1, function()
        if not guiExists then pcall(function() createMenu() end) end
    end)
end