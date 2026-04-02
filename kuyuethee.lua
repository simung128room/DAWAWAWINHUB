--[[
    ╔══════════════════════════════════════════════╗
    ║           DAWAWIN HUB — SOME TOWN            ║
    ║         Full-Featured Admin Script v2        ║
    ╚══════════════════════════════════════════════╝
    Discord: https://discord.gg/YGG4BnHcg
]]

-- ══════════════════════════════════════
--              SERVICES
-- ══════════════════════════════════════
local Players           = game:GetService("Players")
local RunService        = game:GetService("RunService")
local UserInputService  = game:GetService("UserInputService")
local TweenService      = game:GetService("TweenService")
local Lighting          = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer

-- ══════════════════════════════════════
--           HELPER FUNCTIONS
-- ══════════════════════════════════════
local function GetChar()     return LocalPlayer.Character end
local function GetHRP()      local c = GetChar(); return c and c:FindFirstChild("HumanoidRootPart") end
local function GetHumanoid() local c = GetChar(); return c and c:FindFirstChildOfClass("Humanoid") end

-- ══════════════════════════════════════
--            GLOBAL STATE
-- ══════════════════════════════════════
local State = {
    -- Movement
    WalkSpeed       = 16,
    JumpPower       = 50,
    -- Toggles
    InfJump         = false,
    Noclip          = false,
    Fly             = false,
    Invisible       = false,
    GodMode         = false,
    -- Fly internals
    BodyVelocity    = nil,
    BodyGyro        = nil,
    FlySpeed        = 80,
    -- Auto Farm
    AutoFarm        = false,
    AutoFarmConn    = nil,
    -- Invisibility saved parts
    InvisibleParts  = {},
    -- ESP
    ESPEnabled      = false,
    ESPHighlights   = {},
    ESPColor        = Color3.fromRGB(255, 50, 50),
    -- Visual originals
    OriginalBright  = Lighting.Brightness,
    OriginalAmbient = Lighting.Ambient,
    OriginalFog     = Lighting.FogEnd,
    OriginalShadows = Lighting.GlobalShadows,
    OriginalClock   = Lighting.ClockTime,
}

-- ══════════════════════════════════════
--   INVISIBILITY SYSTEM
-- ══════════════════════════════════════
local function ApplyInvisible()
    local char = GetChar()
    if not char then return end
    State.InvisibleParts = {}
    for _, obj in ipairs(char:GetDescendants()) do
        if obj:IsA("BasePart") or obj:IsA("Decal") or obj:IsA("Texture") then
            table.insert(State.InvisibleParts, { obj = obj, t = obj.Transparency })
            obj.Transparency = 1
        end
    end
end

local function RemoveInvisible()
    for _, entry in ipairs(State.InvisibleParts) do
        if entry.obj and entry.obj.Parent then
            entry.obj.Transparency = entry.t
        end
    end
    State.InvisibleParts = {}
end

-- ══════════════════════════════════════
--   ESP SYSTEM
-- ══════════════════════════════════════
local function ClearESP()
    for _, h in pairs(State.ESPHighlights) do
        if h and h.Parent then h:Destroy() end
    end
    State.ESPHighlights = {}
end

local function AddESP(char)
    local h = Instance.new("Highlight")
    h.FillColor           = State.ESPColor
    h.OutlineColor        = Color3.fromRGB(255, 255, 255)
    h.FillTransparency    = 0.5
    h.OutlineTransparency = 0
    h.Adornee = char
    h.Parent  = char
    return h
end

local function BuildESP()
    ClearESP()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            State.ESPHighlights[plr.Name] = AddESP(plr.Character)
        end
    end
end

-- ══════════════════════════════════════
--         RAYFIELD WINDOW
-- ══════════════════════════════════════
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name            = "DAWAWIN HUB | SOME TOWN ",
    LoadingTitle    = "SOME TOWN",
    LoadingSubtitle = "by DEEP",
    ConfigurationSaving = {
        Enabled    = false,
        FolderName = nil,
        FileName   = "DAWAWAWIN_HUB"
    },
    Discord = {
        Enabled       = true,
        Invite        = "YGG4BnHcg",   -- discord.gg/YGG4BnHcg
        RememberJoins = true
    },
    KeySystem = true,
    KeySettings = {
        Title           = "Key | DAWAWAWIN HUB",
        Subtitle        = "Key System",
        -- Note จะแสดงลิ้ง Discord บนหน้า key
        Note            = "Key อยู่ใน Discord\ndiscord.gg/YGG4BnHcg",
        FileName        = "DAWAWAWINHUB1",
        SaveKey         = false,
        GrabKeyFromSite = true,
        Key             = {"https://pastebin.com/raw/mrA9AZjF"}
    }
})

-- Startup notification พร้อมปุ่ม Discord
Rayfield:Notify({
    Title    = "DAWAWIN HUB ✅",
    Content  = "Welcome! Join Discord: discord.gg/YGG4BnHcg",
    Duration = 8,
    Image    = 13047715178,
    Actions  = {
        Discord = {
            Name     = "📢 Join Discord",
            Callback = function()
                pcall(function() setclipboard("https://discord.gg/YGG4BnHcg") end)
                Rayfield:Notify({
                    Title   = "Discord 📋",
                    Content = "คัดลอกลิ้งแล้ว!\ndiscord.gg/YGG4BnHcg",
                    Duration = 4,
                })
            end
        },
        Close = { Name = "Okay!", Callback = function() end },
    },
})

-- Respawn protection
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.6)
    local hum = GetHumanoid()
    if hum then
        hum.WalkSpeed = State.WalkSpeed
        hum.JumpPower = State.JumpPower
        if State.GodMode then
            hum.MaxHealth = math.huge
            hum.Health    = math.huge
        end
    end
    -- Re-apply invisibility
    if State.Invisible then
        task.wait(0.5)
        ApplyInvisible()
    end
    -- Reset fly bodies (destroyed on respawn automatically)
    if State.Fly then
        State.BodyVelocity = nil
        State.BodyGyro     = nil
    end
end)

-- ══════════════════════════════════════
--  TAB 1 — 🏠 HOME
-- ══════════════════════════════════════
local MainTab = Window:CreateTab("Home", "home")

-- Discord button อยู่ด้านบนสุด
MainTab:CreateSection("🔗 Discord")
MainTab:CreateButton({
    Name = "📢 Join Discord  (discord.gg/YGG4BnHcg)",
    Callback = function()
        pcall(function() setclipboard("https://discord.gg/YGG4BnHcg") end)
        Rayfield:Notify({
            Title   = "Discord 📋",
            Content = "คัดลอกลิ้งแล้ว!\ndiscord.gg/YGG4BnHcg",
            Duration = 5,
        })
    end,
})

-- ── Movement ──────────────────────────
MainTab:CreateSection("⚡ Movement")

MainTab:CreateToggle({
    Name = "Infinite Jump", CurrentValue = false, Flag = "InfJump",
    Callback = function(Value)
        State.InfJump = Value
        if Value and not _G.infinJumpStarted then
            _G.infinJumpStarted = true
            UserInputService.JumpRequest:Connect(function()
                if State.InfJump then
                    local hum = GetHumanoid()
                    if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
                end
            end)
        end
    end,
})

MainTab:CreateSlider({
    Name = "WalkSpeed", Range = {16, 350}, Increment = 1,
    Suffix = "Speed", CurrentValue = 16, Flag = "sliderws",
    Callback = function(v) State.WalkSpeed = v; local h = GetHumanoid(); if h then h.WalkSpeed = v end end,
})

MainTab:CreateSlider({
    Name = "JumpPower", Range = {50, 350}, Increment = 1,
    Suffix = "Power", CurrentValue = 50, Flag = "sliderjp",
    Callback = function(v) State.JumpPower = v; local h = GetHumanoid(); if h then h.JumpPower = v end end,
})

-- ── Fly ───────────────────────────────
MainTab:CreateSection("🛸 Fly")

MainTab:CreateToggle({
    Name = "Fly", CurrentValue = false, Flag = "FlyToggle",
    Callback = function(Value)
        State.Fly = Value
        local hrp = GetHRP(); local hum = GetHumanoid()
        if not hrp then return end
        if Value then
            local bv = Instance.new("BodyVelocity")
            bv.Velocity = Vector3.zero; bv.MaxForce = Vector3.new(1e5,1e5,1e5); bv.Parent = hrp
            State.BodyVelocity = bv
            local bg = Instance.new("BodyGyro")
            bg.MaxTorque = Vector3.new(1e5,1e5,1e5); bg.D = 100; bg.Parent = hrp
            State.BodyGyro = bg
            if hum then hum.PlatformStand = true end
        else
            if State.BodyVelocity then State.BodyVelocity:Destroy(); State.BodyVelocity = nil end
            if State.BodyGyro     then State.BodyGyro:Destroy();     State.BodyGyro = nil end
            if hum then hum.PlatformStand = false end
        end
    end,
})

MainTab:CreateSlider({
    Name = "Fly Speed", Range = {20, 400}, Increment = 10,
    Suffix = "Speed", CurrentValue = 80, Flag = "FlySpeed",
    Callback = function(v) State.FlySpeed = v end,
})

-- ── Invisibility ──────────────────────
MainTab:CreateSection("👻 Invisibility")

MainTab:CreateToggle({
    Name = "Invisible (ล่องหน)", CurrentValue = false, Flag = "InvisToggle",
    Callback = function(Value)
        State.Invisible = Value
        if Value then
            ApplyInvisible()
            Rayfield:Notify({ Title = "👻 Invisible ON", Content = "ตัวละครล่องหนแล้ว", Duration = 3 })
        else
            RemoveInvisible()
            Rayfield:Notify({ Title = "👁 Visible", Content = "ตัวละครมองเห็นแล้ว", Duration = 3 })
        end
    end,
})

-- ความโปร่งใสแบบ partial (0% = มองเห็น, 100% = หายตัว)
MainTab:CreateSlider({
    Name = "Transparency Level", Range = {0, 100}, Increment = 5,
    Suffix = "%", CurrentValue = 0, Flag = "TransSlider",
    Callback = function(Value)
        local t = Value / 100
        local char = GetChar()
        if char then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then part.Transparency = t end
            end
        end
    end,
})

-- ── Auto Farm ─────────────────────────
MainTab:CreateSection("🌾 Auto Farm")

MainTab:CreateToggle({
    Name = "Auto Farm", CurrentValue = false, Flag = "AutoFarm",
    Callback = function(Value)
        State.AutoFarm = Value
        if Value then
            local last = 0
            State.AutoFarmConn = RunService.Heartbeat:Connect(function()
                local now = tick()
                if now - last >= 1 then
                    last = now
                    -- ← ใส่ Farm Logic ตรงนี้
                end
            end)
        else
            if State.AutoFarmConn then
                State.AutoFarmConn:Disconnect(); State.AutoFarmConn = nil
            end
        end
    end,
})

-- ══════════════════════════════════════
--  TAB 2 — 🛡 ADMIN PANEL
-- ══════════════════════════════════════
local AdminTab = Window:CreateTab("Admin Panel", "shield")
AdminTab:CreateSection("🎮 Player Controls")

AdminTab:CreateToggle({
    Name = "Noclip (เดินทะลุกำแพง)", CurrentValue = false, Flag = "Noclip",
    Callback = function(v) State.Noclip = v end,
})

AdminTab:CreateToggle({
    Name = "God Mode (HP ไม่ลด)", CurrentValue = false, Flag = "GodMode",
    Callback = function(Value)
        State.GodMode = Value
        local hum = GetHumanoid()
        if hum then
            hum.MaxHealth = Value and math.huge or 100
            hum.Health    = Value and math.huge or 100
        end
    end,
})

AdminTab:CreateToggle({
    Name = "Anti AFK", CurrentValue = false, Flag = "AntiAFK",
    Callback = function(Value)
        _G.AntiAFK = Value
        if Value and not _G.AntiAFKStarted then
            _G.AntiAFKStarted = true
            local VU = game:GetService("VirtualUser")
            LocalPlayer.Idled:Connect(function()
                if _G.AntiAFK then
                    VU:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
                    task.wait(1)
                    VU:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
                end
            end)
        end
    end,
})

AdminTab:CreateToggle({
    Name = "No Fall Damage", CurrentValue = false, Flag = "NoFallDmg",
    Callback = function(Value)
        _G.NoFallDmg = Value
        if Value and not _G.NoFallStarted then
            _G.NoFallStarted = true
            RunService.Heartbeat:Connect(function()
                if not _G.NoFallDmg then return end
                local hum = GetHumanoid()
                if hum and hum:GetState() == Enum.HumanoidStateType.Freefall then
                    hum:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end)
        end
    end,
})

AdminTab:CreateSection("👤 Player Targeting")

AdminTab:CreateInput({
    Name = "Teleport to Player", PlaceholderText = "ใส่ชื่อผู้เล่น",
    RemoveTextAfterFocusLost = false,
    Callback = function(Text)
        local t = Players:FindFirstChild(Text)
        if t and t.Character and t.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = GetHRP()
            if hrp then
                hrp.CFrame = t.Character.HumanoidRootPart.CFrame + Vector3.new(2,0,0)
                Rayfield:Notify({ Title = "Teleported ✅", Content = "วาร์ปไปหา "..Text, Duration = 3 })
            end
        else
            Rayfield:Notify({ Title = "Error ❌", Content = "ไม่พบผู้เล่น: "..Text, Duration = 3 })
        end
    end,
})

AdminTab:CreateInput({
    Name = "Bring Player to You", PlaceholderText = "ใส่ชื่อผู้เล่น",
    RemoveTextAfterFocusLost = false,
    Callback = function(Text)
        local t = Players:FindFirstChild(Text)
        local hrp = GetHRP()
        if t and t.Character and t.Character:FindFirstChild("HumanoidRootPart") and hrp then
            t.Character.HumanoidRootPart.CFrame = hrp.CFrame + Vector3.new(2,0,0)
            Rayfield:Notify({ Title = "Brought ✅", Content = "ดึง "..Text.." มาหาคุณแล้ว", Duration = 3 })
        else
            Rayfield:Notify({ Title = "Error ❌", Content = "ไม่พบผู้เล่น: "..Text, Duration = 3 })
        end
    end,
})

AdminTab:CreateInput({
    Name = "Copy Player Coords", PlaceholderText = "ใส่ชื่อผู้เล่น",
    RemoveTextAfterFocusLost = false,
    Callback = function(Text)
        local t = Players:FindFirstChild(Text)
        if t and t.Character and t.Character:FindFirstChild("HumanoidRootPart") then
            local p = t.Character.HumanoidRootPart.Position
            local s = string.format("X:%.1f Y:%.1f Z:%.1f", p.X, p.Y, p.Z)
            pcall(function() setclipboard(s) end)
            Rayfield:Notify({ Title = "Coords 📋", Content = s, Duration = 5 })
        else
            Rayfield:Notify({ Title = "Error ❌", Content = "ไม่พบผู้เล่น", Duration = 3 })
        end
    end,
})

AdminTab:CreateSection("🖥 Server")

AdminTab:CreateButton({
    Name = "Respawn (เกิดใหม่)",
    Callback = function()
        local ok = pcall(function()
            ReplicatedStorage.Modules.NetworkFramework.NetworkEvent:FireServer("fire", nil, "Respawn")
        end)
        if not ok then LocalPlayer:LoadCharacter() end
    end,
})

AdminTab:CreateButton({
    Name = "List All Players",
    Callback = function()
        local names = {}
        for _, p in ipairs(Players:GetPlayers()) do table.insert(names, p.Name) end
        Rayfield:Notify({ Title = "Players ("..#names..")", Content = table.concat(names, ", "), Duration = 8 })
    end,
})

-- ══════════════════════════════════════
--  TAB 3 — 🗺 TELEPORTS
-- ══════════════════════════════════════
local TPTab = Window:CreateTab("Teleports", "map")
TPTab:CreateSection("📍 Locations")

local Locations = {
    { name = "Spawn Point (จุดเกิด)",   pos = Vector3.new(0,    5,    0)   },
    { name = "Bank (ธนาคาร)",           pos = Vector3.new(100,  5,    100) },
    { name = "Police Station (สถานี)",  pos = Vector3.new(-100, 5,    200) },
    { name = "Hospital (โรงพยาบาล)",   pos = Vector3.new(200,  5,   -100) },
    { name = "Shop (ร้านค้า)",          pos = Vector3.new(-200, 5,   -200) },
    { name = "High Point (บนฟ้า)",      pos = Vector3.new(0,    500,  0)   },
}

for _, loc in ipairs(Locations) do
    TPTab:CreateButton({
        Name = loc.name,
        Callback = function()
            local hrp = GetHRP()
            if hrp then
                hrp.CFrame = CFrame.new(loc.pos)
                Rayfield:Notify({ Title = "Teleport ✅", Content = loc.name, Duration = 2 })
            end
        end,
    })
end

TPTab:CreateSection("🎯 Custom Coords")
local cX, cY, cZ = "0", "5", "0"
TPTab:CreateInput({ Name = "X", PlaceholderText = "0", RemoveTextAfterFocusLost = true, Callback = function(v) cX = v end })
TPTab:CreateInput({ Name = "Y", PlaceholderText = "5", RemoveTextAfterFocusLost = true, Callback = function(v) cY = v end })
TPTab:CreateInput({ Name = "Z", PlaceholderText = "0", RemoveTextAfterFocusLost = true, Callback = function(v) cZ = v end })

TPTab:CreateButton({
    Name = "⬡ Go to Custom Coords",
    Callback = function()
        local x, y, z = tonumber(cX), tonumber(cY), tonumber(cZ)
        if x and y and z then
            local hrp = GetHRP()
            if hrp then
                hrp.CFrame = CFrame.new(x, y, z)
                Rayfield:Notify({ Title = "Teleport ✅", Content = string.format("X:%.0f Y:%.0f Z:%.0f",x,y,z), Duration = 3 })
            end
        else
            Rayfield:Notify({ Title = "Error ❌", Content = "กรอกตัวเลขให้ถูกต้อง", Duration = 3 })
        end
    end,
})

TPTab:CreateSection("💾 Save Position")
local savedCF = nil

TPTab:CreateButton({
    Name = "💾 Save Current Position",
    Callback = function()
        local hrp = GetHRP()
        if hrp then
            savedCF = hrp.CFrame
            local p = hrp.Position
            Rayfield:Notify({ Title = "Saved ✅", Content = string.format("X:%.0f Y:%.0f Z:%.0f",p.X,p.Y,p.Z), Duration = 3 })
        end
    end,
})

TPTab:CreateButton({
    Name = "📍 Return to Saved Position",
    Callback = function()
        if savedCF then
            local hrp = GetHRP()
            if hrp then hrp.CFrame = savedCF; Rayfield:Notify({ Title = "Returned ✅", Content = "กลับไปตำแหน่งที่บันทึก", Duration = 3 }) end
        else
            Rayfield:Notify({ Title = "Error ❌", Content = "ยังไม่ได้บันทึกตำแหน่ง", Duration = 3 })
        end
    end,
})

-- ══════════════════════════════════════
--  TAB 4 — 👁 ESP / VISUALS
-- ══════════════════════════════════════
local ESPTab = Window:CreateTab("ESP", "eye")
ESPTab:CreateSection("👁 Player ESP")

ESPTab:CreateToggle({
    Name = "Player ESP (Highlight)", CurrentValue = false, Flag = "ESPToggle",
    Callback = function(Value)
        State.ESPEnabled = Value
        if Value then
            BuildESP()
            Players.PlayerAdded:Connect(function(plr)
                plr.CharacterAdded:Connect(function(char)
                    task.wait(1)
                    if State.ESPEnabled then
                        State.ESPHighlights[plr.Name] = AddESP(char)
                    end
                end)
            end)
        else
            ClearESP()
        end
    end,
})

ESPTab:CreateDropdown({
    Name = "ESP Color",
    Options = {"Red (แดง)", "Blue (น้ำเงิน)", "Green (เขียว)", "Yellow (เหลือง)", "White (ขาว)", "Pink (ชมพู)"},
    CurrentOption = {"Red (แดง)"}, MultipleOptions = false, Flag = "ESPColor",
    Callback = function(Option)
        local map = {
            ["Red (แดง)"]       = Color3.fromRGB(255, 50,  50),
            ["Blue (น้ำเงิน)"]  = Color3.fromRGB(50,  100, 255),
            ["Green (เขียว)"]   = Color3.fromRGB(50,  255, 100),
            ["Yellow (เหลือง)"] = Color3.fromRGB(255, 230, 50),
            ["White (ขาว)"]     = Color3.fromRGB(255, 255, 255),
            ["Pink (ชมพู)"]     = Color3.fromRGB(255, 100, 200),
        }
        State.ESPColor = map[Option] or Color3.fromRGB(255, 50, 50)
        for _, h in pairs(State.ESPHighlights) do
            if h and h.Parent then h.FillColor = State.ESPColor end
        end
    end,
})

ESPTab:CreateSection("🌟 Visual FX")

ESPTab:CreateToggle({
    Name = "FullBright (สว่างเต็ม)", CurrentValue = false, Flag = "FullBright",
    Callback = function(Value)
        if Value then
            Lighting.Brightness    = 10
            Lighting.ClockTime     = 14
            Lighting.FogEnd        = 1e6
            Lighting.GlobalShadows = false
            Lighting.Ambient       = Color3.fromRGB(178, 178, 178)
        else
            Lighting.Brightness    = State.OriginalBright
            Lighting.Ambient       = State.OriginalAmbient
            Lighting.GlobalShadows = State.OriginalShadows
        end
    end,
})

ESPTab:CreateSlider({
    Name = "Camera FOV", Range = {50, 120}, Increment = 5,
    Suffix = "°", CurrentValue = 70, Flag = "FOVSlider",
    Callback = function(v) workspace.CurrentCamera.FieldOfView = v end,
})

-- Rainbow Name Tag
ESPTab:CreateToggle({
    Name = "Rainbow Name Tag", CurrentValue = false, Flag = "RainbowTag",
    Callback = function(Value)
        _G.RainbowTag = Value
        local char = GetChar()
        if not Value and char then
            local head = char:FindFirstChild("Head")
            if head then
                local g = head:FindFirstChild("RainbowBB"); if g then g:Destroy() end
            end
            return
        end
        if Value and not _G.RainbowStarted then
            _G.RainbowStarted = true
            local hue = 0
            RunService.Heartbeat:Connect(function(dt)
                if not _G.RainbowTag then return end
                hue = (hue + dt * 0.4) % 1
                local c2 = GetChar()
                if not c2 then return end
                local head = c2:FindFirstChild("Head"); if not head then return end
                local gui = head:FindFirstChild("RainbowBB")
                if not gui then
                    gui = Instance.new("BillboardGui")
                    gui.Name = "RainbowBB"
                    gui.Size = UDim2.new(0, 120, 0, 30)
                    gui.StudsOffset = Vector3.new(0, 2.5, 0)
                    gui.AlwaysOnTop = true
                    gui.Parent = head
                    local lbl = Instance.new("TextLabel")
                    lbl.BackgroundTransparency = 1
                    lbl.Size = UDim2.new(1, 0, 1, 0)
                    lbl.Text = LocalPlayer.Name
                    lbl.TextStrokeTransparency = 0
                    lbl.Font = Enum.Font.GothamBold
                    lbl.TextSize = 14
                    lbl.Parent = gui
                end
                local lbl = gui:FindFirstChildOfClass("TextLabel")
                if lbl then lbl.TextColor3 = Color3.fromHSV(hue, 1, 1) end
            end)
        end
    end,
})

-- ══════════════════════════════════════
--  TAB 5 — ⚙ MISC
-- ══════════════════════════════════════
local MiscTab = Window:CreateTab("Misc", "settings")

MiscTab:CreateSection("💬 Chat")
MiscTab:CreateInput({
    Name = "Send Chat Message", PlaceholderText = "พิมพ์ข้อความ",
    RemoveTextAfterFocusLost = true,
    Callback = function(Text)
        local ok = pcall(function()
            ReplicatedStorage:WaitForChild("DefaultChatSystemChatEvents")
                :WaitForChild("SayMessageRequest"):FireServer(Text, "All")
        end)
        if not ok then
            pcall(function()
                game:GetService("Chat"):Chat(GetChar() and GetChar():FindFirstChild("Head"), Text)
            end)
        end
    end,
})

MiscTab:CreateSection("🌍 World Settings")

MiscTab:CreateSlider({
    Name = "Time of Day", Range = {0, 24}, Increment = 1,
    Suffix = ":00", CurrentValue = 14, Flag = "TimeSlider",
    Callback = function(v) Lighting.ClockTime = v end,
})

MiscTab:CreateSlider({
    Name = "Gravity", Range = {10, 300}, Increment = 5,
    Suffix = "", CurrentValue = 196, Flag = "GravitySlider",
    Callback = function(v) workspace.Gravity = v end,
})

MiscTab:CreateSlider({
    Name = "Fog Distance", Range = {100, 10000}, Increment = 100,
    Suffix = " studs", CurrentValue = 10000, Flag = "FogSlider",
    Callback = function(v) Lighting.FogEnd = v end,
})

MiscTab:CreateSection("🔧 Utilities")

MiscTab:CreateButton({
    Name = "Show My Coordinates",
    Callback = function()
        local hrp = GetHRP()
        if hrp then
            local p = hrp.Position
            local s = string.format("X: %.1f  Y: %.1f  Z: %.1f", p.X, p.Y, p.Z)
            pcall(function() setclipboard(string.format("%.1f, %.1f, %.1f", p.X, p.Y, p.Z)) end)
            Rayfield:Notify({ Title = "My Coords 📍", Content = s, Duration = 6 })
        end
    end,
})

MiscTab:CreateButton({
    Name = "Reset All Settings",
    Callback = function()
        State.WalkSpeed = 16; State.JumpPower = 50
        local hum = GetHumanoid()
        if hum then hum.WalkSpeed = 16; hum.JumpPower = 50 end
        workspace.Gravity = 196
        workspace.CurrentCamera.FieldOfView = 70
        Lighting.ClockTime     = State.OriginalClock
        Lighting.Brightness    = State.OriginalBright
        Lighting.Ambient       = State.OriginalAmbient
        Lighting.FogEnd        = State.OriginalFog
        Lighting.GlobalShadows = State.OriginalShadows
        Rayfield:Notify({ Title = "Reset ✅", Content = "ค่าทุกอย่างกลับสู่ปกติแล้ว", Duration = 3 })
    end,
})

MiscTab:CreateSection("🔗 Discord")

MiscTab:CreateButton({
    Name = "📢 Join Discord  (discord.gg/YGG4BnHcg)",
    Callback = function()
        pcall(function() setclipboard("https://discord.gg/YGG4BnHcg") end)
        Rayfield:Notify({
            Title   = "Discord 📋",
            Content = "คัดลอกแล้ว!\ndiscord.gg/YGG4BnHcg",
            Duration = 5,
        })
    end,
})

MiscTab:CreateSection("🗑 System")

MiscTab:CreateButton({
    Name = "Destroy GUI (ปิดสคริปต์)",
    Callback = function()
        if State.BodyVelocity then State.BodyVelocity:Destroy() end
        if State.BodyGyro     then State.BodyGyro:Destroy()     end
        if State.AutoFarmConn then State.AutoFarmConn:Disconnect() end
        RemoveInvisible()
        ClearESP()
        local hum = GetHumanoid()
        if hum then
            hum.WalkSpeed = 16; hum.JumpPower = 50
            hum.PlatformStand = false
            hum.MaxHealth = 100; hum.Health = 100
        end
        workspace.Gravity = 196
        Rayfield:Destroy()
    end,
})

-- ══════════════════════════════════════
--        RUNTIME LOOP (Heartbeat)
-- ══════════════════════════════════════
RunService.Heartbeat:Connect(function(dt)

    -- ── Noclip ───────────────────────
    if State.Noclip then
        local char = GetChar()
        if char then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = false end
            end
        end
    end

    -- ── Keep Invisible ───────────────
    -- re-apply each frame so new parts (accessories etc.) also stay hidden
    if State.Invisible then
        local char = GetChar()
        if char then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") and part.Transparency ~= 1 then
                    part.Transparency = 1
                end
            end
        end
    end

    -- ── Fly ──────────────────────────
    if State.Fly and State.BodyVelocity and GetHRP() then
        local cam     = workspace.CurrentCamera
        local hum     = GetHumanoid()
        local moveDir = Vector3.zero
        if hum and hum.MoveDirection.Magnitude > 0.1 then
            moveDir = hum.MoveDirection
        end
        State.BodyVelocity.Velocity = moveDir * State.FlySpeed
        State.BodyGyro.CFrame       = cam.CFrame
    end

end)

print("[DAWAWIN HUB v2] Loaded ✔  discord.gg/YGG4BnHcg")
