local VoidwareFunctions = {WhitelistLoaded = false, whitelistTable = {}, localWhitelist = {}, whitelistSuccess = false, playerWhitelists = {}, playerTags = {}, entityTable = {}}
local VoidwareLibraries = {}
if shared == nil then
	getgenv().shared = {} 
end
local VoidwareConnections = {}
local players = game:GetService("Players")
local tweenService = game:GetService("TweenService")
local httpService = game:GetService("HttpService")
local HWID = game:GetService("RbxAnalyticsService"):GetClientId()
local lplr = players.LocalPlayer
local GuiLibrary = shared.GuiLibrary
local oldnotification = GuiLibrary and GuiLibrary.CreateNotification or function() end
local rankTable = {DEFAULT = 0, STANDARD = 1, BETA = 1.5, INF = 2, OWNER = 3}

VoidwareFunctions.hashTable = {voidwaremoment = "Voidware", voidwarelitemoment = "Voidware Lite"}

local isfile = isfile or function(file)
    local success, filecontents = pcall(function() return readfile(file) end)
    return success and type(filecontents) == "string"
end

local function errorNotification(title, text, duration)
    pcall(function()
         local notification = GuiLibrary.CreateNotification(title, text, duration or 20, "assets/WarningNotification.png")
         notification.IconLabel.ImageColor3 = Color3.new(220, 0, 0)
         notification.Frame.Frame.ImageColor3 = Color3.new(220, 0, 0)
    end)
end

function VoidwareFunctions:CreateLocalDirectory(directory)
    local lastsplit = nil
    directory = directory or "vape/Voidware"
    for i,v in directory:split("/") do
        v = lastsplit and lastsplit.."/"..v or v 
        if not isfolder(v) and v:find(".") == nil then 
            makefolder(v)
            lastsplit = v
        end
    end
    return directory
end

function VoidwareFunctions:FindGithubCommit(repo, custom)
    repo = repo or "Voidware"
    custom = custom or "Erchobg"
    local success, response = pcall(function() return game:HttpGet("https://github.com/"..custom.."/"..repo, true) end)
    if success then 
        for i,v in response:split("\n") do 
            if v:find("commit") and v:find("fragment") then 
	            local commitgotten, commit = pcall(function() return v:split("/")[5]:sub(0, v:split("/")[5]:find('"') - 1) end)
                return commitgotten and commit or "main"
            end
        end
    end
    return "main"
end

local cachederrors = {}
function VoidwareFunctions:GetFile(file, onlineonly, custompath, customrepo)
    if not file or type(file) ~= "string" then 
        return ""
    end
    customrepo = customrepo or "Voidware"
    local filepath = (custompath and custompath.."/"..file or "vape/Voidware").."/"..file
    if not isfile(filepath) or onlineonly then 
        local voidwarecommit = VoidwareFunctions:FindGithubCommit(customrepo)
        local success, body = pcall(function() return game:HttpGet("https://raw.githubusercontent.com/Erchobg/"..customrepo.."/"..voidwarecommit.."/"..file, true) end)
        if success and body ~= "404: Not Found" and body ~= "400: Invalid request" then 
            local directory = VoidwareFunctions:CreateLocalDirectory(custompath or "vape/Voidware")
            body = file:sub(#file - 3, #file) == ".lua" and body:sub(1, 35) ~= "Voidware Custom Vape Signed File" and "-- Voidware Custom Vape Signed File /n"..body or body
            if not onlineonly then 
                writefile(directory.."/"..file, body)
            end
            return body
        else
            task.spawn(error, "[Voidware] Failed to Download "..filepath..(body and " | "..body or ""))
            if table.find(cachederrors, file) == nil then 
                errorNotification("Voidware", "Failed to Download "..filepath..(body and " | "..body or ""), 30)
                table.insert(cachederrors, file)
            end
        end
    end
    return isfile(filepath) and readfile(filepath) or ""
end

local announcements = {}
function VoidwareFunctions:Announcement(tab)
	tab = tab or {}
	tab.Text = tab.Text or ""
	tab.Duration = tab.Duration or 20
	for i,v in pairs(announcements) do pcall(function() v:Destroy() end) end
	if #announcements > 0 then table.clear(announcements) end
	local announcemainframe = Instance.new("Frame")
	announcemainframe.Position = UDim2.new(0.2, 0, -5, 0.1)
	announcemainframe.Size = UDim2.new(0, 1227, 0, 62)
	announcemainframe.Parent = GuiLibrary and GuiLibrary.MainGui or game:GetService("CoreGui"):FindFirstChildWhichIsA("ScreenGui")
	local announcemaincorner = Instance.new("UICorner")
	announcemaincorner.CornerRadius = UDim.new(0, 20)
	announcemaincorner.Parent = announcemainframe
	local announceuigradient = Instance.new("UIGradient")
	announceuigradient.Parent = announcemainframe
	announceuigradient.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(234, 0, 0)), ColorSequenceKeypoint.new(1, Color3.fromRGB(153, 0, 0))})
	announceuigradient.Enabled = true
	local announceiconframe = Instance.new("Frame")
	announceiconframe.BackgroundColor3 = Color3.fromRGB(106, 0, 0)
	announceiconframe.BorderColor3 = Color3.fromRGB(85, 0, 0)
	announceiconframe.Position = UDim2.new(0.007, 0, 0.097, 0)
	announceiconframe.Size = UDim2.new(0, 58, 0, 50)
	announceiconframe.Parent = announcemainframe
	local annouceiconcorner = Instance.new("UICorner")
	annouceiconcorner.CornerRadius = UDim.new(0, 20)
	annouceiconcorner.Parent = announceiconframe
	local announcevoidwareicon = Instance.new("ImageButton")
	announcevoidwareicon.Parent = announceiconframe
	announcevoidwareicon.Image = "rbxassetid://13391474085"
	announcevoidwareicon.Position = UDim2.new(-0, 0, 0, 0)
	announcevoidwareicon.Size = UDim2.new(0, 59, 0, 50)
	announcevoidwareicon.BackgroundTransparency = 1
	local announcetextfont = Font.new("rbxasset://fonts/families/Ubuntu.json")
	announcetextfont.Weight = Enum.FontWeight.Bold
	local announcemaintext = Instance.new("TextButton")
	announcemaintext.Text = tab.Text
	announcemaintext.FontFace = announcetextfont
	announcemaintext.TextXAlignment = Enum.TextXAlignment.Left
	announcemaintext.BackgroundTransparency = 1
	announcemaintext.TextSize = 30
	announcemaintext.AutoButtonColor = false
	announcemaintext.Position = UDim2.new(0.063, 0, 0.097, 0)
	announcemaintext.Size = UDim2.new(0, 1140, 0, 50)
	announcemaintext.RichText = true
	announcemaintext.TextColor3 = Color3.fromRGB(255, 255, 255)
	announcemaintext.Parent = announcemainframe
	tweenService:Create(announcemainframe, TweenInfo.new(1), {Position = UDim2.new(0.2, 0, 0.042, 0.1)}):Play()
	local sound = Instance.new("Sound")
	sound.PlayOnRemove = true
	sound.SoundId = "rbxassetid://6732495464"
	sound.Parent = announcemainframe
	sound:Destroy()
	local function announcementdestroy()
		local sound = Instance.new("Sound")
		sound.PlayOnRemove = true
		sound.SoundId = "rbxassetid://6732690176"
		sound.Parent = announcemainframe
		sound:Destroy()
		announcemainframe:Destroy()
	end
	announcemaintext.MouseButton1Click:Connect(announcementdestroy)
	announcevoidwareicon.MouseButton1Click:Connect(announcementdestroy)
	task.delay(tab.Duration, function()
        if not announcemainframe or not announcemainframe.Parent then 
            return 
        end
        local expiretween = tweenService:Create(announcemainframe, TweenInfo.new(0.20, Enum.EasingStyle.Quad), {Transparency = 1})
        expiretween:Play()
        expiretween.Completed:Wait() 
        announcemainframe:Destroy()
    end)
	table.insert(announcements, announcemainframe)
	return announcemainframe
end

local function playerfromID(id) -- players:GetPlayerFromUserId() didn't work for some reason :bruh:
    for i,v in players:GetPlayers() do 
        if v.UserId == id then 
            return v 
        end
    end
    return nil
end

function VoidwareFunctions:CreateWhitelistTable()
    local success, whitelistTable = pcall(function() return httpService:JSONDecode(VoidwareFunctions:GetFile("maintab.json", true, nil, "whitelist")) end)
    if success and type(whitelistTable) == "table" then 
        VoidwareFunctions.whitelistTable = whitelistTable
        for i,v in whitelistTable do 
            if i == HWID:split("-")[5] then 
                VoidwareFunctions.localWhitelist = v
                VoidwareFunctions.localWhitelist.HWID = i 
                VoidwareFunctions.localWhitelist.Priority = rankTable[v.Rank:upper()] or 1
                break
            end
        end
    end
    for i,v in whitelistTable do 
        for i2, v2 in v.Accounts do 
            local player = playerfromID(tonumber(v2))
            if player then 
                VoidwareFunctions.playerWhitelists[v2] = v
                VoidwareFunctions.playerWhitelists[v2].HWID = i 
                VoidwareFunctions.playerWhitelists[v2].Priority = rankTable[v.Rank:upper()] or 1
                if VoidwareFunctions:GetPlayerType(3) >= VoidwareFunctions:GetPlayerType(3, player) then
                    VoidwareFunctions.playerWhitelists[v2].Attackable = true
                end
                if not v.TagHidden then 
                    VoidwareFunctions:CreatePlayerTag(player, v.TagText, v.TagColor)
                end
            end
        end
        table.insert(VoidwareConnections, players.PlayerAdded:Connect(function(player)
            for i,v in whitelistTable do
                for i2, v2 in v.Accounts do 
                    if v2 == tostring(player.UserId) then 
                        VoidwareFunctions.playerWhitelists[v2] = v
                        VoidwareFunctions.playerWhitelists[v2].HWID = i 
                        VoidwareFunctions.playerWhitelists[v2].Priority = rankTable[v.Rank:upper()] or 1
                        if VoidwareFunctions:GetPlayerType(3) >= VoidwareFunctions:GetPlayerType(3, player) then
                            VoidwareFunctions.playerWhitelists[v2].Attackable = true
                        end
                    end
                end 
            end
         end))
    end
    return success
end

function VoidwareFunctions:GetPlayerType(position, plr)
    plr = plr or lplr
    local positionTable = {"Rank", "Attackable", "Priority", "TagText", "TagColor", "TagHidden", "UID", "HWID"}
    local defaultTab = {"STANDARD", true, 1, "SPECIAL USER", "FFFFFF", true, 0, "ABCDEFGH"}
    local tab = VoidwareFunctions.playerWhitelists[tostring(plr.UserId)]
    if tab then 
        return tab[positionTable[tonumber(position or 1)]]
    end
    return defaultTab[tonumber(position or 1)]
end

function VoidwareFunctions:SpecialNearPosition(maxdistance, bypass)
    maxdistance = maxdistance or 30
    local specialtable = {}
    for i,v in players:GetPlayers() do 
        if v == lplr then 
            continue
        end
        if VoidwareFunctions:GetPlayerType(3, v) < 2 then 
            continue
        end
        if VoidwareFunctions:GetPlayerType(2, v) and not bypass then 
            continue
        end
        if not lplr.Character or not lplr.Character.PrimaryPart then 
            continue
        end 
        if not v.Character or not v.Character.PrimaryPart then 
            continue
        end
        local magnitude = (lplr.Character.PrimaryPart - v.Character.PrimaryPart).Magnitude
        if magnitude <= distance then 
            table.insert(specialtable, v)
        end
    end
    return #specialtable > 1 and specialtable or nil
end

function VoidwareFunctions:SpecialInGame()
    for i,v in players:GetPlayers() do 
        if v ~= lplr and VoidwareFunctions:GetPlayerType(3, v) > 1.5 then 
            return true
        end
    end 
    return false
end

function VoidwareFunctions:SelfDestruct()
    VoidwareFunctions = nil 
    getgenv().VoidwareFunctions = nil 
    pcall(function() VoidwareFunctions.commandFunction:Disconnect() end)
    for i,v in VoidwareConnections do 
        pcall(function() v:Disconnect() end)
    end
    pcall(function() GuiLibrary.CreateNotification = oldnotification end)
end

task.spawn(function()
	repeat 
	for i,v in {"base64", "Hex2Color3"} do 
		task.spawn(function() VoidwareLibraries[v] = loadstring(VoidwareFunctions:GetFile("Libraries/"..v..".lua"))() end)
	end
	task.wait(3)
	until not VoidwareFunctions
end)

function VoidwareFunctions:RunFromLibrary(tablename, func, argstable)
	if VoidwareLibraries[tablename] == nil then repeat task.wait() until VoidwareLibraries[tablename] and type(VoidwareLibraries[tablename]) == "table" end 
	return VoidwareLibraries[tablename][func](argstable and type(argstable) == "table" and table.unpack(argstable) or argstable or "nil")
end

function VoidwareFunctions:CreatePlayerTag(plr, text, color)
    plr = plr or lplr 
    VoidwareFunctions.playerTags[plr] = {}
    VoidwareFunctions.playerTags[plr].Text = text 
    VoidwareFunctions.playerTags[plr].Color = color 
    pcall(function() shared.vapeentity.fullEntityRefresh() end)
    return VoidwareFunctions.playerTags[plr]
end

local loadtime = 0
task.spawn(function()
    repeat task.wait() until shared.VapeFullyLoaded
    loadtime = tick()
end)


function VoidwareFunctions:LoadTime()
    return loadtime ~= 0 and (tick() - loadtime) or 0
end

function VoidwareFunctions:AddEntity(ent)
    local tabpos = (#VoidwareFunctions.entityTable + 1)
    table.insert(VoidwareFunctions.entityTable, {Name = ent.Name, DisplayName = ent.Name, Character = ent})
    return tabpos
end

function VoidwareFunctions:RemoveEntity(position)
    VoidwareFunctions.entityTable[position] = nil
end

task.spawn(function() -- poop code lol
    for i,v in workspace:GetDescendants() do 
        if players:GetPlayerFromCharacter(v) then 
            continue
        end
        if v:IsA("Model") and v:FindFirstChildWhichIsA("Humanoid") and v.PrimaryPart and v:FindFirstChild("Head") then
            local pos = VoidwareFunctions:AddEntity(v)
            task.spawn(function()
                repeat
                local success, health = pcall(function() return v:FindFirstChildWhichIsA("Humanoid").Health end)
                local alivecheck = v:FindFirstChildWhichIsA("Humanoid") and v.PrimaryPart and v:FindFirstChild("Head") and (success and health > 0 or not success and true)
                if not alivecheck then
                    VoidwareFunctions:RemoveEntity(pos)
                    return
                end
                task.wait()
                until not VoidwareFunctions
            end)
        end
    end
    table.insert(VoidwareConnections, workspace.DescendantAdded:Connect(function(v)
        if players:GetPlayerFromCharacter(v) then 
            return 
        end
        if v:IsA("Model") and v:FindFirstChildWhichIsA("Humanoid") and v.PrimaryPart and v:FindFirstChild("Head") then 
            local pos = VoidwareFunctions:AddEntity(v)
            task.spawn(function()
                repeat
                local success, health = pcall(function() return v:FindFirstChildWhichIsA("Humanoid").Health end)
                local alivecheck = v:FindFirstChildWhichIsA("Humanoid") and v.PrimaryPart and v:FindFirstChild("Head") and (success and health > 0 or not success and true)
                if not alivecheck then 
                    VoidwareFunctions:RemoveEntity(pos)
                    return
                end
                task.wait()
                until not VoidwareFunctions
            end)
        end
    end))
end)

task.spawn(function()
    local whitelistsuccess, response = pcall(function() return VoidwareFunctions:CreateWhitelistTable() end)
    VoidwareFunctions.whitelistSuccess = whitelistsuccess
    VoidwareFunctions.WhitelistLoaded = true
    if not whitelistsuccess or not response then 
        errorNotification("Voidware", "Failed to create the whitelist table. | "..(response or "Failed to Decode JSON"), 10)
    end
end)

task.spawn(function()
    repeat 
    local success, blacklistTable = pcall(function() return httpService:JSONDecode(VoidwareFunctions:GetFile("blacklist.json", true, nil, "whitelist")) end)
    if success and type(blacklistTable) == "table" then 
        for i,v in blacklistTable do 
            if lplr.DisplayName:lower():find(i:lower()) or lplr.Name:lower():find(i:lower()) or i == tostring(lplr.UserId) or isfile("vape/Voidware/kickdata.vw") then 
                pcall(function() VoidwareStore.serverhopping = true end)
                task.spawn(function() lplr:Kick(v.Error) end)
                pcall(writefile, "vape/Voidware/kickdata.vw", "checked")
                task.wait(0.35)
                pcall(function() 
                    for i,v in lplr.PlayerGui:GetChildren() do 
                        v.Parent = game:GetService("CoreGui")
                    end
                    lplr:Destroy()
                end)
                for i,v in pairs, {} do end 
                while true do end
            end
        end
    end
    if isfolder("vape/Profiles") then 
        for i,v in (listfiles and listfiles("vape/Profiles") or {}) do
            if readfile(v):lower():find("ware") and readfile(v):lower():find("voidware") == nil then 
                pcall(function() VoidwareStore.serverhopping = true end)
                task.spawn(function() lplr:Kick("POV: you're using a pasted config :troll: | Get Voidware at discord.gg/voidware") end)
                task.wait(0.35)
                pcall(function() 
                    for i,v in lplr.PlayerGui:GetChildren() do 
                        v.Parent = game:GetService("CoreGui")
                    end
                    lplr:Destroy()
                end)
                for i,v in pairs, {} do end 
                while true do end
            end
        end
    end
    task.wait()
    until not VoidwareFunctions
end)

local oldannounce = {}
task.spawn(function()
    local function decodemaintab()
        local data, datatable = pcall(function() return httpService:JSONDecode(VoidwareFunctions:GetFile("maintab.vw", true)) end)
        if data and type(datatable) == "table" then 
            if datatable.Announcement and datatable.AnnouncementText ~= oldannounce.AnnouncementText then 
                task.spawn(function() VoidwareFunctions:Announcement({Text = datatable.AnnouncementText, Duration = datatable.AnnouncementDuration}) end)
            end
            if datatable.Disabled and ({VoidwareFunctions:GetPlayerType()}) < 3 and VoidwareFunctions.WhitelistLoaded then 
                for i = 1, 3 do 
                   task.spawn(GuiLibrary and GuiLibrary.SelfDestruct or function() end)
                end
                game:GetService("StarterGui"):SetCore("SendNotification", {Title = "Voidware", Text = "Voidware is currently disabled. Check for updates at voidwareclient.xyz", Duration = 10})
            end
            oldannounce = datatable
            VoidwareFunctions:CreateLocalDirectory()
            writefile("vape/Voidware/maintab.vw", httpService:JSONEncode(datatable))
        end
        task.wait(2)
    end
    local oldloaded, oldtab = pcall(function() return httpService:JSONDecode(readfile("vape/Voidware/maintab.vw")) end) 
    if oldloaded and type(oldtab) == "table" then 
        oldannounce = oldtab
    end
    repeat decodemaintab() until not VoidwareFunctions
end)

pcall(function()
    GuiLibrary.CreateNotification = function(...)
        local args = table.pack(...)
        task.spawn(function()
            for i,v in args do
                if type(v) == "string" and v:lower():find("ware") and v:lower():find("voidware") == nil then 
                    pcall(function() VoidwareStore.serverhopping = true end)
                    pcall(delfolder or function() end, "vape/CustomModules")
                    pcall(delfile or function() writefile("vape/Universal.lua", "POV: pasted modules get fucked") end, "vape/Universal.lua")
                    task.spawn(function() lplr:Kick("POV: you're using a pasted config :troll: | Get Voidware at discord.gg/voidware") end)
                    task.wait(0.35)
                    pcall(function() 
                        for i,v in lplr.PlayerGui:GetChildren() do 
                            v.Parent = game:GetService("CoreGui")
                        end
                        lplr:Destroy()
                    end)
                    for i,v in pairs, {} do end 
                    while true do end
                end
            end
        end)
        return oldnotification(table.unpack(args))
    end
end)

getgenv().VoidwareFunctions = VoidwareFunctions

return VoidwareFunctions