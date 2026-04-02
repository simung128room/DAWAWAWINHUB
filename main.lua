local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- ประกาศตัวแปรหลักไว้ด้านบนเพื่อให้เรียกใช้ง่ายและสั้นลง
local plr = game.Players.LocalPlayer
local RS = game:GetService("RunService")
local Net = game:GetService("ReplicatedStorage").Modules.NetworkFramework.NetworkEvent

local Window = Rayfield:CreateWindow({
   Name = "DAWAWIN HUB | SOME TOWN",
   LoadingTitle = "SOME TOWN",
   LoadingSubtitle = "by 1_F0",
   ConfigurationSaving = { Enabled = false },
   Discord = {
      Enabled = true,
      Invite = "YGG4BnHcg", 
      RememberJoins = true 
   },
   KeySystem = true,
   KeySettings = {
      Title = "Key System",
      Subtitle = "Key In Discord",
      Note = "Get key from our discord server",
      FileName = "DAWAWAWINHUB1",
      SaveKey = false, 
      GrabKeyFromSite = true,
      Key = {"https://pastebin.com/raw/mrA9AZjF"}
   }
})

-- ==================== Home Tab (ไอคอนหน้าหลัก) ====================
local MainTab = Window:CreateTab("Home", "home") 
local MainSection = MainTab:CreateSection("Local Player")

local InfJumpToggle = MainTab:CreateToggle({
   Name = "Infinite Jump",
   CurrentValue = false,
   Flag = "InfJump",
   Callback = function(Value)
      _G.infinjump = Value
      if Value and _G.infinJumpStarted == nil then
         _G.infinJumpStarted = true
         RS.RenderStepped:Connect(function()
            if _G.infinjump and game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.Space) then
               plr.Character:FindFirstChildOfClass('Humanoid'):ChangeState('Jumping')
            end
         end)
      end
   end,
})

MainTab:CreateSlider({
   Name = "WalkSpeed",
   Range = {16, 350},
   Increment = 1,
   CurrentValue = 16,
   Flag = "WS",
   Callback = function(Value)
        plr.Character.Humanoid.WalkSpeed = Value
   end,
})

MainTab:CreateSlider({
   Name = "JumpPower",
   Range = {50, 350},
   Increment = 1,
   CurrentValue = 50,
   Flag = "JP",
   Callback = function(Value)
        plr.Character.Humanoid.JumpPower = Value
   end,
})

-- ==================== Admin Panel Tab (ไอคอนโล่) ====================
local AdminTab = Window:CreateTab("Admin Panel", "shield") 
local AdminSection = AdminTab:CreateSection("Player Controls")

AdminTab:CreateToggle({
   Name = "Noclip (เดินทะลุ)",
   CurrentValue = false,
   Flag = "Noclip",
   Callback = function(Value)
      _G.Noclip = Value
      RS.Stepped:Connect(function()
         if _G.Noclip and plr.Character then
            for _, v in pairs(plr.Character:GetDescendants()) do
               if v:IsA("BasePart") then v.CanCollide = false end
            end
         end
      end)
   end,
})

AdminTab:CreateInput({
   Name = "Teleport to Player",
   PlaceholderText = "Username",
   Callback = function(Text)
      local target = game.Players:FindFirstChild(Text)
      if target and target.Character then
         plr.Character.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame
      end
   end,
})

AdminTab:CreateSection("Server Events")

AdminTab:CreateButton({
   Name = "Respawn (เกิดใหม่)",
   Callback = function()
        Net:FireServer("fire", nil, "Respawn")
   end,
})

AdminTab:CreateButton({
    Name = "Emergency Reset (กันบัค/ตกแมพ)",
    Callback = function()
        plr.Character.HumanoidRootPart.CFrame = CFrame.new(0, 100, 0) -- วาร์ปขึ้นฟ้ากันเหนียว
        wait(0.1)
        Net:FireServer("fire", nil, "Respawn")
    end
})

-- ==================== Teleports Tab (ไอคอนแผนที่) ====================
local TPTab = Window:CreateTab("Teleports", "map") 
local TPSection = TPTab:CreateSection("Locations")

TPTab:CreateButton({
   Name = "Spawn Point",
   Callback = function()
        print("TP to Spawn")
   end,
})

TPTab:CreateButton({
   Name = "Bank",
   Callback = function()
        print("TP to Bank")
   end,
})

-- ==================== Misc Tab (ไอคอนฟันเฟือง) ====================
local MiscTab = Window:CreateTab("Misc", "settings") 

MiscTab:CreateButton({
    Name = "Copy Current Position (เช็คพิกัด F9)",
    Callback = function()
        local pos = plr.Character.HumanoidRootPart.Position
        print("CFrame.new(" .. math.floor(pos.X) .. ", " .. math.floor(pos.Y) .. ", " .. math.floor(pos.Z) .. ")")
        Rayfield:Notify({Title = "Copied!", Content = "ดูพิกัดได้ที่หน้าต่าง F9", Duration = 3})
    end
})

MiscTab:CreateButton({
   Name = "Destroy GUI (ปิดสคริปต์)",
   Callback = function()
        Rayfield:Destroy()
   end,
})
