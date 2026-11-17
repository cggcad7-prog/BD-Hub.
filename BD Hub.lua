--[[
=====================================================================
    BD Hub [Profile & Fully Scrollable Edition]
    - ใส่รูปโปรไฟล์ Roblox (ID: 72593755596490) ทั้งในหน้าใส่คีย์และหน้าหลัก
    - เปิดระบบ Scrollbar ให้เลื่อนดูฟังก์ชันในหน้าต่างได้สมบูรณ์
    - ปลดล็อกหน้าต่าง UI ให้ลากขยับย้ายตำแหน่งได้อิสระ
    - วง FOV สีสายรุ้ง (Rainbow Gradient) ขนาดมาตรฐาน 250
    - Tab 1 (Aimbot): Aim Lock, เปิด/ปิดวง FOV, Silent Curve, Big Hitbox
    - Tab 2 (Visuals): ระบบมองทะลุครบถ้วน (กรอบสี่เหลี่ยม / เส้นกลางจอ / กรอบเลือด)
=====================================================================
--]]

if getgenv().BDHub_Loaded then
    warn("BD Hub is already running!")
    return
end
getgenv().BDHub_Loaded = true

-- โหลดไลบรารี WindUI
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

-- สร้างหน้าต่าง BD Hub พร้อมใส่รูปโปรไฟล์ที่ KeySystem Thumbnail และ User Profile
local Window = WindUI:CreateWindow({
    Title = "BD Hub",
    Icon = "door-open",
    Author = "by BD Team",
    Folder = "BDHub",
    
    Size = UDim2.fromOffset(580, 460),
    MinSize = Vector2.new(560, 350),
    MaxSize = Vector2.new(850, 560),
    ToggleKey = Enum.KeyCode.LeftShift,
    Transparent = true,
    Theme = "Dark",
    Resizable = true,
    Draggable = true, -- ปลดล็อกให้ลากขยับหน้าต่างได้อิสระ
    SideBarWidth = 200,
    BackgroundImageTransparency = 0.42,
    HideSearchBar = true,
    ScrollBarEnabled = true, -- เปิดให้เลื่อนขึ้น-ลงดูฟังก์ชันใน UI ได้สมบูรณ์
    
    User = {
        Enabled = true,
        Anonymous = false,
        Name = "BD Hub User",
        Image = "rbxthumb://type=AvatarHeadShot&id=72593755596490&w=420&h=420",
        Callback = function()
            print("BD Hub User Clicked")
        end,
    },
    
    KeySystem = { 
        Key = { "bd-38263-0372-Hub" },
        Note = "กรุณาใส่คีย์เพื่อเข้าใช้งาน BD Hub",
        Thumbnail = {
            -- เปลี่ยนเป็นรูปโปรไฟล์จาก Roblox User ID ของคุณ (แทนข้อความตรงกลางเดิม)
            Image = "rbxthumb://type=AvatarHeadShot&id=72593755596490&w=420&h=420",
            Title = "BD Hub",
        },
        URL = "",
        SaveKey = false,
    },
})

-- =====================================================================
-- 📑 สร้าง 2 แท็บหลัก (Aimbot และ Visuals)
-- =====================================================================
local AimbotTab = Window:Tab({ Title = "Aimbot", Icon = "crosshair" })
local VisualsTab = Window:Tab({ Title = "Visuals", Icon = "eye" })

-- ตัวแปรตั้งค่าการทำงาน (กำหนดค่า FOV Fix ไว้ที่ 250)
local CONFIG = {
    AIMLOCK_ENABLED = false,
    FOV_ENABLED     = false,
    FOV_RADIUS      = 250,  
    BIGHITBOX       = false,
    CURVE_ENABLED   = false,
    
    -- แยกการตั้งค่าระบบมองทะลุ (Visuals)
    BOX_ESP         = false,
    SNAPLINE_ESP    = false,
    HEALTHBAR_ESP   = false,
    
    SMOOTHNESS      = 0.3,
}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- =====================================================================
-- 🌈 สร้างวง FOV แบบ UI Frame "สีสายรุ้ง" (Rainbow Gradient)
-- =====================================================================
local parentGui
if gethui then
    local ok, hui = pcall(gethui)
    if ok and hui then parentGui = hui end
end
parentGui = parentGui or LocalPlayer:WaitForChild("PlayerGui")

if parentGui:FindFirstChild("BD_FOV_UI") then
    parentGui.BD_FOV_UI:Destroy()
end

local fovGui = Instance.new("ScreenGui")
fovGui.Name = "BD_FOV_UI"
fovGui.IgnoreGuiInset = true
fovGui.ResetOnSpawn = false
fovGui.DisplayOrder = 999
fovGui.Parent = parentGui

local fovFrame = Instance.new("Frame")
fovFrame.Name = "FOVCircle"
fovFrame.AnchorPoint = Vector2.new(0.5, 0.5)
fovFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
fovFrame.Size = UDim2.fromOffset(CONFIG.FOV_RADIUS * 2, CONFIG.FOV_RADIUS * 2)
fovFrame.BackgroundTransparency = 1
fovFrame.Visible = false
fovFrame.Parent = fovGui

local fovCorner = Instance.new("UICorner")
fovCorner.CornerRadius = UDim.new(1, 0)
fovCorner.Parent = fovFrame

local fovStroke = Instance.new("UIStroke")
fovStroke.Thickness = 2.5
fovStroke.Transparency = 0.05
fovStroke.Parent = fovFrame

-- ไล่เฉดสีสายรุ้ง (Rainbow ColorSequence)
local fovGradient = Instance.new("UIGradient")
fovGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 0, 0)),     -- แดง
    ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 165, 0)),   -- ส้ม
    ColorSequenceKeypoint.new(0.33, Color3.fromRGB(255, 255, 0)),   -- เหลือง
    ColorSequenceKeypoint.new(0.50, Color3.fromRGB(0, 255, 0)),     -- เขียว
    ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 0, 255)),     -- น้ำเงิน
    ColorSequenceKeypoint.new(0.83, Color3.fromRGB(75, 0, 130)),    -- คราม
    ColorSequenceKeypoint.new(1.00, Color3.fromRGB(238, 130, 238)), -- ม่วง
})
fovGradient.Parent = fovStroke


-- =====================================================================
-- 🎯 TAB 1: Aimbot (วง FOV สีสายรุ้งหมุนวน)
-- =====================================================================
AimbotTab:Section({ Title = "ระบบการต่อสู้และล็อกเป้า" })

AimbotTab:Toggle({
    Title = "เปิด/ปิด ระบบช่วยเล็ง (Aim Lock)",
    Default = false,
    Callback = function(v)
        CONFIG.AIMLOCK_ENABLED = v
    end
})

AimbotTab:Toggle({
    Title = "เปิดแสดงวง FOV (สีสายรุ้ง)",
    Default = false,
    Callback = function(v)
        CONFIG.FOV_ENABLED = v
        if fovFrame then
            fovFrame.Visible = v
        end
    end
})

AimbotTab:Toggle({
    Title = "ขยายตัวศัตรู / เพิ่มระยะดาเมจ (Client-Side)",
    Default = false,
    Callback = function(v)
        CONFIG.BIGHITBOX = v
    end
})

AimbotTab:Toggle({
    Title = "เปิด/ปิด ระบบลูกกระสุนโค้ง (Silent Curve)",
    Default = false,
    Callback = function(v)
        CONFIG.CURVE_ENABLED = v
    end
})


-- =====================================================================
-- 👁️ TAB 2: Visuals (ระบบมองทะลุครบถ้วน: กรอบสี่เหลี่ยม, เส้นกลางจอ, กรอบเลือด)
-- =====================================================================
VisualsTab:Section({ Title = "ตั้งค่าระบบมองทะลุ (ESP Settings)" })

VisualsTab:Toggle({
    Title = "เปิด/ปิด กรอบสี่เหลี่ยม (Box ESP)",
    Default = false,
    Callback = function(v)
        CONFIG.BOX_ESP = v
    end
})

VisualsTab:Toggle({
    Title = "เปิด/ปิด เส้นจากกลางจอ (Snaplines)",
    Default = false,
    Callback = function(v)
        CONFIG.SNAPLINE_ESP = v
    end
})

VisualsTab:Toggle({
    Title = "เปิด/ปิด กรอบเลือด (Health Bar)",
    Default = false,
    Callback = function(v)
        CONFIG.HEALTHBAR_ESP = v
    end
})


-- =====================================================================
-- ⚙️ ENGINE & LOGIC (ระบบเรนเดอร์ หมุนสีสายรุ้ง และคำนวณเป้าหมาย)
-- =====================================================================

local lockedTarget = nil
local ESPCache = {}

local function CleanupESP(p)
    pcall(function()
        if ESPCache[p] then
            if ESPCache[p].Box then ESPCache[p].Box:Remove() end
            if ESPCache[p].Tracer then ESPCache[p].Tracer:Remove() end
            if ESPCache[p].HB_Bg then ESPCache[p].HB_Bg:Remove() end
            if ESPCache[p].HB_Fill then ESPCache[p].HB_Fill:Remove() end
            ESPCache[p] = nil
        end
        if lockedTarget == p then
            lockedTarget = nil
        end
    end)
end

Players.PlayerRemoving:Connect(CleanupESP)

-- ฟังก์ชันคำนวณเป้าหมาย (หมุนจอเปลี่ยนเป้า + Sticky Lock)
local function getTargetHead()
    if not Camera then return nil, nil end
    local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    local radius = CONFIG.FOV_RADIUS

    if lockedTarget and lockedTarget.Character then
        local hum = lockedTarget.Character:FindFirstChildOfClass("Humanoid")
        local head = lockedTarget.Character:FindFirstChild("Head")
        if hum and hum.Health > 0 and head then
            local pos, onScreen = Camera:WorldToViewportPoint(head.Position)
            if onScreen then
                local dist = (Vector2.new(pos.X, pos.Y) - screenCenter).Magnitude
                if dist <= radius then
                    return head, lockedTarget
                end
            end
        end
    end

    lockedTarget = nil
    local shortestDist = radius
    local bestHead = nil
    local bestPlayer = nil

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            local hum = plr.Character:FindFirstChildOfClass("Humanoid")
            local head = plr.Character:FindFirstChild("Head")
            if hum and hum.Health > 0 and head then
                local pos, onScreen = Camera:WorldToViewportPoint(head.Position)
                if onScreen then
                    local dist = (Vector2.new(pos.X, pos.Y) - screenCenter).Magnitude
                    if dist < shortestDist then
                        shortestDist = dist
                        bestHead = head
                        bestPlayer = plr
                    end
                end
            end
        end
    end

    lockedTarget = bestPlayer
    return bestHead, lockedTarget
end

-- ลูปการทำงานหลัก
RunService.RenderStepped:Connect(function()
    pcall(function()
        if not Camera then return end

        local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        local currentRadius = CONFIG.FOV_RADIUS

        -- 1. อัปเดตขนาดวง FOV และหมุนสีสายรุ้งแบบไดนามิก
        if fovFrame then
            fovFrame.Size = UDim2.fromOffset(currentRadius * 2, currentRadius * 2)
            fovFrame.Visible = CONFIG.FOV_ENABLED
            if fovGradient then
                fovGradient.Rotation = (tick() * 60) % 360
            end
        end

        -- 2. ขยาย Hitbox / ดาเมจ
        if CONFIG.BIGHITBOX then
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character then
                    local rootPart = player.Character:FindFirstChild("HumanoidRootPart")
                    local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
                    if rootPart and humanoid and humanoid.Health > 0 then
                        rootPart.Size = Vector3.new(4, 7, 4)
                        rootPart.Transparency = 0.9
                        rootPart.CanCollide = false
                    end
                end
            end
        end

        local targetHead, currentTargetPlr = getTargetHead()
        local anyESPEnabled = CONFIG.BOX_ESP or CONFIG.SNAPLINE_ESP or CONFIG.HEALTHBAR_ESP

        -- 3. จัดการระบบมองทะลุ ESP (แยกเปิด/ปิดอิสระตามแท็บ Visuals)
        if anyESPEnabled then
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character then
                    local char = player.Character
                    local rootPart = char:FindFirstChild("HumanoidRootPart")
                    local humanoid = char:FindFirstChildOfClass("Humanoid")

                    if rootPart and humanoid and humanoid.Health > 0 then
                        if not ESPCache[player] then
                            local box = Drawing.new("Square")
                            box.Thickness = 1.5
                            box.Filled = false

                            local tracer = Drawing.new("Line")
                            tracer.Thickness = 1
                            tracer.Transparency = 0.6

                            local hb_bg = Drawing.new("Line")
                            hb_bg.Thickness = 3
                            hb_bg.Color = Color3.fromRGB(0, 0, 0)

                            local hb_fill = Drawing.new("Line")
                            hb_fill.Thickness = 1.5

                            ESPCache[player] = {Box = box, Tracer = tracer, HB_Bg = hb_bg, HB_Fill = hb_fill}
                        end

                        local pos, onScreen = Camera:WorldToViewportPoint(rootPart.Position)
                        if onScreen then
                            local scaleFactor = 1 / (pos.Z * math.tan(math.rad(Camera.FieldOfView * 0.5)) * 2) * 1000
                            local w = math.floor(4 * scaleFactor)
                            local h = math.floor(5.5 * scaleFactor)
                            local boxPos = Vector2.new(pos.X - w / 2, pos.Y - h / 2)
                            local targetColor = (player == currentTargetPlr) and Color3.fromRGB(255, 50, 50) or Color3.fromRGB(0, 255, 128)

                            -- A. กรอบสี่เหลี่ยม (Box ESP)
                            local cacheBox = ESPCache[player].Box
                            if CONFIG.BOX_ESP then
                                cacheBox.Color = targetColor
                                cacheBox.Size = Vector2.new(w, h)
                                cacheBox.Position = boxPos
                                cacheBox.Visible = true
                            else
                                cacheBox.Visible = false
                            end

                            -- B. เส้นจากกลางจอ (Snaplines)
                            local cacheTracer = ESPCache[player].Tracer
                            if CONFIG.SNAPLINE_ESP then
                                cacheTracer.Color = targetColor
                                cacheTracer.From = screenCenter
                                cacheTracer.To = Vector2.new(pos.X, pos.Y + h / 2)
                                cacheTracer.Visible = true
                            else
                                cacheTracer.Visible = false
                            end

                            -- C. กรอบเลือด (Health Bar)
                            local cacheBg = ESPCache[player].HB_Bg
                            local cacheFill = ESPCache[player].HB_Fill
                            if CONFIG.HEALTHBAR_ESP then
                                local healthPercent = math.clamp(humanoid.Health / humanoid.MaxHealth, 0, 1)
                                local barHeight = h * healthPercent

                                cacheBg.From = Vector2.new(boxPos.X - 6, boxPos.Y + h)
                                cacheBg.To = Vector2.new(boxPos.X - 6, boxPos.Y)
                                cacheBg.Visible = true

                                cacheFill.From = Vector2.new(boxPos.X - 6, boxPos.Y + h)
                                cacheFill.To = Vector2.new(boxPos.X - 6, boxPos.Y + (h - barHeight))
                                cacheFill.Color = Color3.fromRGB(0, 255, 0)
                                cacheFill.Visible = true
                            else
                                cacheBg.Visible = false
                                cacheFill.Visible = false
                            end
                        else
                            if ESPCache[player] then
                                ESPCache[player].Box.Visible = false
                                ESPCache[player].Tracer.Visible = false
                                ESPCache[player].HB_Bg.Visible = false
                                ESPCache[player].HB_Fill.Visible = false
                            end
                        end
                    else
                        CleanupESP(player)
                    end
                end
            end
        else
            for p, _ in pairs(ESPCache) do
                CleanupESP(p)
            end
        end

        -- 4. ระบบช่วยเล็ง Aim Lock (ทำงานเมื่อกดคลิกขวา)
        if CONFIG.AIMLOCK_ENABLED and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
            if targetHead then
                local currentCFrame = Camera.CFrame
                local targetCFrame = CFrame.new(currentCFrame.Position, targetHead.Position)
                Camera.CFrame = currentCFrame:Lerp(targetCFrame, CONFIG.SMOOTHNESS)
            end
        end
    end)
end)

-- =====================================================================
-- 🎯 5. ระบบลูกกระสุนโค้ง (Silent Curve Hook)
-- =====================================================================
if hookmetamethod and getnamecallmethod and newcclosure then
    local oldNamecall
    oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
        if checkcaller and not checkcaller() then
            return oldNamecall(self, ...)
        end

        local method = getnamecallmethod()
        local args = {...}

        if method == "FireServer" and CONFIG.CURVE_ENABLED then
            local name = tostring(self.Name):lower()
            if name:find("shoot") or name:find("fire") or name:find("bullet") or name:find("hit") then
                local targetHead, _ = getTargetHead()
                if targetHead then
                    for i, arg in ipairs(args) do
                        if typeof(arg) == "Vector3" then
                            args[i] = targetHead.Position
                        elseif typeof(arg) == "CFrame" then
                            args[i] = CFrame.new(arg.Position, targetHead.Position)
                        end
                    end
                end
            end
        end

        return oldNamecall(self, unpack(args))
    end))
end

WindUI:Notify({
    Title = "BD Hub",
    Content = "🌈 BD Hub [Profile & Scrollable Edition] Loaded Successfully!",
    Duration = 5
})
