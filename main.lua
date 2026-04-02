local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "DAWAWIN HUB | SOME TOWN Admin", -- เอาอิโมจิออกเพื่อความสะอาดตา
   LoadingTitle = "SOME TOWN",
   LoadingSubtitle = "by 1_F0",
   ConfigurationSaving = {
      Enabled = false,
      FolderName = nil, 
      FileName = "DAWAWAWIN_HUB"
   },
   Discord = {
      Enabled = true,
      Invite = "YGG4BnHcg", 
      RememberJoins = true 
   },
   KeySystem = true,
   KeySettings = {
      Title = "Key | DAWAWAWIN HUB",
      Subtitle = "Key System",
      Note = "Key In Discord Server",
      FileName = "DAWAWAWINHUB1",
      SaveKey = false, 
      GrabKeyFromSite = true,
      Key = {"https://pastebin.com/raw/mrA9AZjF"}
   }
})

-- ==================== Home Tab ====================
-- ใช้ไอคอน "home" แทนอิโมจิ 🏠
local MainTab = Window:CreateTab("Home", "home") 
local MainSection = MainTab:CreateSection("Local Player")

Rayfield:Notify({
   Title = "Script Executed!",
   Content = "Welcome to DAWAWIN HUB for Some Town",
   Duration = 5,
   Image = 13047715178,
   Actions = {
      Ignore = {
         Name = "Okay!",
         Callback = function()
            print("User acknowledged notification")
         end
      },
   },
})

local InfJumpToggle = MainTab:CreateToggle({
   Name = "Infinite Jump",
   CurrentValue = false,
   Flag = "InfJump",
   Callback = function(Value)
      _G.infinjump = Value
      if Value and _G.infinJumpStarted == nil then
         _G.infinJumpStarted = true
         game.StarterGui:SetCore("SendNotification", {Title="DAWAWIN Hub"; Text="Infinite Jump Ready!"; Duration=5;})
         local plr = game:GetService('Players').LocalPlayer
         local m = plr:GetMouse()
         m.KeyDown:connect(function(k)
            if _G.infinjump then
               if k:byte() == 32 then
                  local humanoid = game:GetService'Players'.LocalPlayer.Character:FindFirstChildOfClass('Humanoid')
                  humanoid:ChangeState('Jumping')
                  wait()
                  humanoid:ChangeState('Seated')
               end
            end
         end)
      end
   end,
})

local SliderWS = MainTab:CreateSlider({
   Name = "WalkSpeed Slider",
   Range = {16, 350},
   Increment = 1,
   Suffix = "Speed",
   CurrentValue = 16,
   Flag = "sliderws",
   Callback = function(Value)
        game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = Value
   end,
})

local SliderJP = MainTab:CreateSlider({
   Name = "JumpPower Slider",
   Range = {50, 350},
   Increment = 1,
   Suffix = "Power",
   CurrentValue = 50,
   Flag = "sliderjp",
   Callback = function(Value)
        game.Players.LocalPlayer.Character.Humanoid.JumpPower = Value
   end,
})

-- ==================== Admin Panel Tab ====================
-- ใช้ไอคอน "shield" (โล่) แทนอิโมจิ 🛡️
local AdminTab = Window:CreateTab("Admin Panel", "shield") 
local AdminSection = AdminTab:CreateSection("Player Controls")

local NoclipToggle = AdminTab:CreateToggle({
   Name = "Noclip (เดินทะลุกำแพง)",
   CurrentValue = false,
   Flag = "Noclip",
   Callback = function(Value)
      _G.Noclip = Value
      local player = game.Players.LocalPlayer
      game:GetService("RunService").Stepped:Connect(function()
         if _G.Noclip then
            for _, v in pairs(player.Character:GetDescendants()) do
               if v:IsA("BasePart") then
                  v.CanCollide = false
               end
            end
         end
      end)
   end,
})

local TargetPlayerInput = AdminTab:CreateInput({
   Name = "Teleport to Player (ใส่ชื่อผู้เล่น)",
   PlaceholderText = "Username",
   RemoveTextAfterFocusLost = false,
   Callback = function(Text)
      local targetPlayer = game.Players:FindFirstChild(Text)
      if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
         game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = targetPlayer.Character.HumanoidRootPart.CFrame
         Rayfield:Notify({Title = "Teleported", Content = "วาร์ปไปหา " .. Text .. " แล้ว", Duration = 3})
      else
         Rayfield:Notify({Title = "Error", Content = "ไม่พบผู้เล่นนี้ในเซิร์ฟเวอร์", Duration = 3})
      end
   end,
})

local AdminSection2 = AdminTab:CreateSection("Server Events")

-- ปุ่มใหม่ที่คุณต้องการ (Respawn)
local RespawnButton = AdminTab:CreateButton({
   Name = "Respawn (เกิดใหม่)",
   Callback = function()
        local args = {
            [1] = "fire",
            [3] = "Respawn"
        }
        -- ทำการ FireServer ไปยัง RemoteEvent ตามที่คุณระบุ
        game:GetService("ReplicatedStorage").Modules.NetworkFramework.NetworkEvent:FireServer(unpack(args))
   end,
})

-- ==================== Teleports Tab ====================
-- ใช้ไอคอน "map" (แผนที่) แทนอิโมจิ 🏝
local TPTab = Window:CreateTab("Teleports", "map") 
local TPSection = TPTab:CreateSection("Locations")

local Button1 = TPTab:CreateButton({
   Name = "Spawn Point (จุดเกิด)",
   Callback = function()
        -- ใส่ CFrame ของจุดเกิด
        print("Teleporting to Spawn")
   end,
})

local Button2 = TPTab:CreateButton({
   Name = "Bank (ธนาคาร)",
   Callback = function()
        -- ใส่ CFrame ของธนาคาร
        print("Teleporting to Bank")
   end,
})

-- ==================== Misc Tab ====================
-- ใช้ไอคอน "settings" (ฟันเฟือง) แทนอิโมจิ 🎲
local MiscTab = Window:CreateTab("Misc", "settings") 
local MiscSection = MiscTab:CreateSection("Settings & Extras")

local ButtonDestroy = MiscTab:CreateButton({
   Name = "Destroy GUI (ปิดสคริปต์)",
   Callback = function()
        Rayfield:Destroy()
   end,
})
