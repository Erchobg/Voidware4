local RenderFunctions = {WhitelistLoaded = false, whitelistTable = {}, localWhitelist = {}, configUsers = {}, whitelistSuccess = false, playerWhitelists = {}, commands = {}, playerTags = {}, entityTable = {}}
local RenderLibraries = {}
local RenderConnections = {}
local players = game:GetService('Players')
local HWID = game:GetService("RbxAnalyticsService"):GetClientId()
local tweenService = game:GetService('TweenService')
local httpService = game:GetService('HttpService')
local textChatService = game:GetService('TextChatService')
local lplr = players.LocalPlayer
local GuiLibrary = (shared and shared.GuiLibrary)
local rankTable = {DEFAULT = 0, STANDARD = 1, BOOSTER = 1.5, BETA = 1.6, INF = 2, OWNER = 3}
local httprequest = (http and http.request or http_request or fluxus and fluxus.request or request or function() return {Body = '[]', StatusCode = 404, StatusText = 'bad exploit'} end)

local RenderFunctions = setmetatable(RenderFunctions, {
    __newindex = function(tab, i, v) 
        if getgenv().RenderFunctions and type(v) ~= 'function' then 
            for i,v in pairs, ({}) do end
        end
        rawset(tab, i, v) 
    end,
    __tostring = function(tab) 
        return 'Core render table object.'
    end
})

RenderFunctions.playerWhitelists = setmetatable({}, {
    __newindex = function(tab, i, v) 
        if getgenv().RenderFunctions then 
            for i,v in pairs, ({}) do end
        end
        rawset(tab, i, v) 
    end,
    __tostring = function(tab) 
        return 'Voidware4 whitelist table object.'
    end
})

RenderFunctions.commands = setmetatable({}, {
    __newindex = function(tab, i, v) 
        if type(v) ~= 'function' then 
            for i,v in pairs, ({}) do end
        end
        rawset(tab, i, v) 
    end,
    __tostring = function(tab) 
        return 'Voidware4 whitelist command functions.'
    end
})

rankTable = setmetatable(rankTable, {
    __newindex = function(tab, i, v) 
        if getgenv().RenderFunctions then 
            for i,v in pairs, ({}) do end
        end
        rawset(tab, i, v) 
    end
})

RenderFunctions.hashTable = {rendermoment = 'Voidware4', renderlitemoment = 'Voidware4 Lite', redrendermoment = 'Voidware4 Red'}

local isfile = isfile or function(file)
    local success, filecontents = pcall(function() return readfile(file) end)
    return success and type(filecontents) == 'string'
end

local function errorNotification(title, text, duration)
    pcall(function()
         local notification = GuiLibrary.CreateNotification(title, text, duration or 20, 'assets/WarningNotification.png')
         notification.IconLabel.ImageColor3 = Color3.new(220, 0, 0)
         notification.Frame.Frame.ImageColor3 = Color3.new(220, 0, 0)
    end)
end

function RenderFunctions:CreateLocalDirectory(directory)
    local lastsplit = nil
    directory = directory or "vape/Voidware4"
    for i,v in directory:split("/") do
        v = lastsplit and lastsplit.."/"..v or v 
        if not isfolder(v) and v:find(".") == nil then 
            makefolder(v)
            lastsplit = v
        end
    end
    return directory
end

function RenderFunctions:CreatePlayerTag(plr, text, color)
    plr = plr or lplr 
    RenderFunctions.playerTags[plr] = {}
    RenderFunctions.playerTags[plr].Text = text 
    RenderFunctions.playerTags[plr].Color = color 
    pcall(function() shared.vapeentity.fullEntityRefresh() end)
    return RenderFunctions.playerTags[plr]
end

function RenderFunctions:RefreshLocalEnv()
    local signal = Instance.new('BindableEvent')
    local start = tick()
    local coreinstalled = 0
    for i,v in next, ({'Libraries', 'scripts'}) do  
        if isfolder('vape/Voidware4/'..v) then 
            delfolder('vape/Voidware4/'..v) 
            RenderFunctions:DebugWarning('vape/Voidware4/'..v, 'folder has been deleted due to updates.')
        end
    end
    for i,v in next, ({'Universal.lua', 'MainScript.lua', 'NewMainScript.lua', 'GuiLibrary.lua'}) do 
        task.spawn(function()
            local contents = game:HttpGet('https://raw.githubusercontent.com/Erchobg/'..RenderFunctions:GithubHash()..'/packages/'..v)
            if contents ~= '404: Not Found' then 
                contents = (tostring(contents:split('\n')[1]):find('Voidware4 Custom Vape Signed File') and contents or '-- Voidware4 Custom Vape Signed File\n'..contents)
                if isfolder('vape') then 
                    RenderFunctions:DebugWarning('vape/', v, 'has been overwritten due to updates.')
                    writefile('vape/'..v, contents) 
                    coreinstalled = (coreinstalled + 1)
                end
            end 
        end)
    end
    local files = httpService:JSONDecode(game:HttpGet('https://api.github.com/repos/Erchobg/Voidware4/contents/packages'))
    local customsinstalled = 0
    local totalcustoms = 0
    for i,v in next, files do 
        totalcustoms = (totalcustoms + 1)
        task.spawn(function() 
            local number = tonumber(tostring(v.name:split('.')[1]))
            if number then 
				local contents = game:HttpGet('https://raw.githubusercontent.com/Erchobg/Voidware4/'..RenderFunctions:GithubHash()..'/packages/'..v.name) 
                contents = (tostring(contents:split('\n')[1]):find('Voidware4 Custom Vape Signed File') and contents or '-- Voidware4 Custom Vape Signed File\n'..contents)
				writefile('vape/CustomModules/'..v.name, contents)
                customsinstalled = (customsinstalled + 1)
                RenderFunctions:DebugWarning('vape/Voidware4/'..v, 'was overwritten due to updates.')
            end 
        end)
    end
    task.spawn(function()
        repeat task.wait() until (coreinstalled == 4 and customsinstalled == totalcustoms)
        RenderFunctions:DebugWarning('The local environment has been refreshed fully.')
        signal:Fire(tick() - start)
    end)
    return signal
end

function RenderFunctions:GithubHash(repo, owner)
    local html = httprequest({Url = 'https://github.com/'..(owner or 'Erchobg')..'/'..(repo or 'Voidware4')}).Body -- had to use this cause "Arceus X" is absolute bs LMFAO
	for i,v in next, html:split("\n") do 
	    if v:find('commit') and v:find('fragment') then 
	       local str = v:split("/")[5]
	       local success, commit = pcall(function() return str:sub(0, v:split('/')[5]:find('"') - 1) end) 
           if success and commit then 
               return commit 
           end
	    end
	end
    return (repo == 'Voidware4' and 'source' or 'main')
end

local cachederrors = {}
function RenderFunctions:GetFile(file, onlineonly, custompath, customrepo)
    if not file or type(file) ~= 'string' then 
        return ''
    end
    customrepo = customrepo or 'Voidware4'
    local filepath = (custompath and custompath..'/'..file or 'vape/Voidware4')..'/'..file
    if not isfile(filepath) or onlineonly then 
        local Rendercommit = RenderFunctions:GithubHash(customrepo)
        local success, body = pcall(function() return game:HttpGet('https://raw.githubusercontent.com/Erchobg/'..customrepo..'/'..Rendercommit..'/'..file, true) end)
        if success and body ~= '404: Not Found' and body ~= '400: Invalid request' then 
            local directory = RenderFunctions:CreateLocalDirectory(filepath)
            body = file:sub(#file - 3, #file) == '.lua' and body:sub(1, 35) ~= 'Voidware4 Custom Vape Signed File' and '-- Voidware4 Custom Vape Signed File /n'..body or body
            if not onlineonly then 
                writefile(directory.."/"..file, body)
            end
            return body
        else
            --task.spawn(error, '[Voidware4] Failed to Download '..filepath..(body and ' | '..body or ''))
            --if table.find(cachederrors, file) == nil then 
              --  errorNotification('Voidware4', 'Failed to Download '..filepath..(body and ' | '..body or ''), 30)
                --table.insert(cachederrors, file)
            --end
        end
    end
    return isfile(filepath) and readfile(filepath) or ""
end

local announcements = {}
function RenderFunctions:Announcement(tab)
	tab = tab or {}
	tab.Text = tab.Text or ''
	tab.Duration = tab.Duration or 20
	for i,v in next, announcements do 
        pcall(function() v:Destroy() end) 
    end
	table.clear(announcements)
	local announcemainframe = Instance.new('Frame')
	announcemainframe.Position = UDim2.new(0.2, 0, -5, 0.1)
	announcemainframe.Size = UDim2.new(0, 1227, 0, 62)
	announcemainframe.Parent = (GuiLibrary and GuiLibrary.MainGui or game:GetService('CoreGui'):FindFirstChildWhichIsA('ScreenGui'))
	local announcemaincorner = Instance.new('UICorner')
	announcemaincorner.CornerRadius = UDim.new(0, 20)
	announcemaincorner.Parent = announcemainframe
	local announceuigradient = Instance.new('UIGradient')
	announceuigradient.Parent = announcemainframe
	announceuigradient.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(234, 0, 0)), ColorSequenceKeypoint.new(1, Color3.fromRGB(153, 0, 0))})
	announceuigradient.Enabled = true
	local announceiconframe = Instance.new('Frame')
	announceiconframe.BackgroundColor3 = Color3.fromRGB(106, 0, 0)
	announceiconframe.BorderColor3 = Color3.fromRGB(85, 0, 0)
	announceiconframe.Position = UDim2.new(0.007, 0, 0.097, 0)
	announceiconframe.Size = UDim2.new(0, 58, 0, 50)
	announceiconframe.Parent = announcemainframe
	local annouceiconcorner = Instance.new('UICorner')
	annouceiconcorner.CornerRadius = UDim.new(0, 20)
	annouceiconcorner.Parent = announceiconframe
	local announceRendericon = Instance.new('ImageButton')
	announceRendericon.Parent = announceiconframe
	announceRendericon.Image = 'rbxassetid://13391474085'
	announceRendericon.Position = UDim2.new(-0, 0, 0, 0)
	announceRendericon.Size = UDim2.new(0, 59, 0, 50)
	announceRendericon.BackgroundTransparency = 1
	local announcetextfont = Font.new('rbxasset://fonts/families/Ubuntu.json')
	announcetextfont.Weight = Enum.FontWeight.Bold
	local announcemaintext = Instance.new('TextButton')
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
	local sound = Instance.new('Sound')
	sound.PlayOnRemove = true
	sound.SoundId = 'rbxassetid://6732495464'
	sound.Parent = announcemainframe
	sound:Destroy()
	local function announcementdestroy()
		local sound = Instance.new('Sound')
		sound.PlayOnRemove = true
		sound.SoundId = 'rbxassetid://6732690176'
		sound.Parent = announcemainframe
		sound:Destroy()
		announcemainframe:Destroy()
	end
	announcemaintext.MouseButton1Click:Connect(announcementdestroy)
	announceRendericon.MouseButton1Click:Connect(announcementdestroy)
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
    for i,v in next, players:GetPlayers() do 
        if v.UserId == tonumber(id) then 
            return v 
        end
    end
end

function RenderFunctions:SpecialNearPosition(maxdistance, bypass)
    maxdistance = maxdistance or 30
    local specialtable = {}
    for i,v in players:GetPlayers() do 
        if v == lplr then 
            continue
        end
        if RenderFunctions:GetPlayerType(3, v) < 2 then 
            continue
        end
        if RenderFunctions:GetPlayerType(2, v) and not bypass then 
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

function RenderFunctions:SpecialInGame()
    for i,v in players:GetPlayers() do 
        if v ~= lplr and RenderFunctions:GetPlayerType(3, v) > 1.5 then 
            return true
        end
    end 
    return false
end

function RenderFunctions:DebugPrint(...)
    if RenderDebug then 
        task.spawn(print, table.concat({...}, ' ')) 
    end
end

function RenderFunctions:DebugWarning(...)
    if RenderDebug then 
        task.spawn(warn, table.concat({...}, ' ')) 
    end
end

function RenderFunctions:DebugError(...)
    if RenderDebug then
        task.spawn(error, table.concat({...}, ' '))
    end
end

function RenderFunctions:CreateWhitelistTable()
    local success, whitelistTable = pcall(function() return httpService:JSONDecode(RenderFunctions:GetFile("maintabb.json", true, nil, "whitelist")) end) -- i made this error myself
    if success and type(whitelistTable) == "table" then 
        RenderFunctions.whitelistTable = whitelistTable
        for i,v in whitelistTable do 
            if i == HWID:split("-")[5] then 
                RenderFunctions.localWhitelist = v
                RenderFunctions.localWhitelist.HWID = i 
                RenderFunctions.localWhitelist.Priority = rankTable[v.Rank:upper()] or 1
                break
            end
        end
    end
    for i,v in whitelistTable do 
        for i2, v2 in v.Accounts do 
            local player = playerfromID(tonumber(v2))
            if player then 
                RenderFunctions.playerWhitelists[v2] = v
                RenderFunctions.playerWhitelists[v2].HWID = i 
                RenderFunctions.playerWhitelists[v2].Priority = rankTable[v.Rank:upper()] or 1
                if RenderFunctions:GetPlayerType(3) >= RenderFunctions:GetPlayerType(3, player) then
                    RenderFunctions.playerWhitelists[v2].Attackable = true
                end
                if not v.TagHidden then 
                    RenderFunctions:CreatePlayerTag(player, v.TagText, v.TagColor)
                end
            end
        end
        table.insert(RenderConnections, players.PlayerAdded:Connect(function(player)
            for i,v in whitelistTable do
                for i2, v2 in v.Accounts do 
                    if v2 == tostring(player.UserId) then 
                        RenderFunctions.playerWhitelists[v2] = v
                        RenderFunctions.playerWhitelists[v2].HWID = i 
                        RenderFunctions.playerWhitelists[v2].Priority = rankTable[v.Rank:upper()] or 1
                        if RenderFunctions:GetPlayerType(3) >= RenderFunctions:GetPlayerType(3, player) then
                            RenderFunctions.playerWhitelists[v2].Attackable = true
                        end
                    end
                end 
            end
         end))
    end
    return success
end

function RenderFunctions:GetPlayerType(position, plr)
    plr = plr or lplr
    local positionTable = {"Rank", "Attackable", "Priority", "TagText", "TagColor", "TagHidden", "UID", "HWID"}
    local defaultTab = {"STANDARD", true, 1, "SPECIAL USER", "FFFFFF", true, 0, "ABCDEFGH"}
    local tab = RenderFunctions.playerWhitelists[tostring(plr.UserId)]
    if tab then 
        return tab[positionTable[tonumber(position or 1)]]
    end
    return defaultTab[tonumber(position or 1)]
end

function RenderFunctions:SelfDestruct()
    RenderFunctions = nil 
    getgenv().RenderFunctions = nil 
    pcall(function() RenderFunctions.commandFunction:Disconnect() end)
    for i,v in RenderConnections do 
        pcall(function() v:Disconnect() end)
    end
    pcall(function() GuiLibrary.CreateNotification = oldnotification end)
end

function RenderFunctions:RunFromLibrary(tablename, func, argstable)
	if RenderLibraries[tablename] == nil then repeat task.wait() until RenderLibraries[tablename] and type(RenderLibraries[tablename]) == "table" end 
	return RenderLibraries[tablename][func](argstable and type(argstable) == "table" and table.unpack(argstable) or argstable or "nil")
end

local loadtime = 0
task.spawn(function()
    repeat task.wait() until shared.VapeFullyLoaded
    loadtime = tick()
end)

function RenderFunctions:LoadTime()
    return loadtime ~= 0 and (tick() - loadtime) or 0
end

function RenderFunctions:AddEntity(ent)
    local tabpos = (#RenderFunctions.entityTable + 1)
    table.insert(RenderFunctions.entityTable, {Name = ent.Name, DisplayName = ent.Name, Character = ent})
    return tabpos
end

function RenderFunctions:GetAllSpecial(nobooster)
    local special = {}
    local prio = (nobooster and 1.5 or 1)
    for i,v in next, players:GetPlayers() do 
        if v ~= lplr and RenderFunctions:GetPlayerType(3, v) > prio then 
            table.insert(special, v)
        end
    end 
    return special
end

function RenderFunctions:RemoveEntity(position)
    RenderFunctions.entityTable[position] = nil
end

function RenderFunctions:AddCommand(name, func)
    rawset(RenderFunctions.commands, name, func or function() end)
end

function RenderFunctions:RemoveCommand(name) 
    rawset(RenderFunctions.commands, name, nil)
end

task.spawn(function() -- poop code lol
    for i,v in workspace:GetDescendants() do 
        if players:GetPlayerFromCharacter(v) then 
            continue
        end
        if v:IsA("Model") and v:FindFirstChildWhichIsA("Humanoid") and v.PrimaryPart and v:FindFirstChild("Head") then
            local pos = RenderFunctions:AddEntity(v)
            task.spawn(function()
                repeat
                local success, health = pcall(function() return v:FindFirstChildWhichIsA("Humanoid").Health end)
                local alivecheck = v:FindFirstChildWhichIsA("Humanoid") and v.PrimaryPart and v:FindFirstChild("Head") and (success and health > 0 or not success and true)
                if not alivecheck then
                    RenderFunctions:RemoveEntity(pos)
                    return
                end
                task.wait()
                until not RenderFunctions
            end)
        end
    end
    table.insert(RenderConnections, workspace.DescendantAdded:Connect(function(v)
        if players:GetPlayerFromCharacter(v) then 
            return 
        end
        if v:IsA("Model") and v:FindFirstChildWhichIsA("Humanoid") and v.PrimaryPart and v:FindFirstChild("Head") then 
            local pos = RenderFunctions:AddEntity(v)
            task.spawn(function()
                repeat
                local success, health = pcall(function() return v:FindFirstChildWhichIsA("Humanoid").Health end)
                local alivecheck = v:FindFirstChildWhichIsA("Humanoid") and v.PrimaryPart and v:FindFirstChild("Head") and (success and health > 0 or not success and true)
                if not alivecheck then 
                    RenderFunctions:RemoveEntity(pos)
                    return
                end
                task.wait()
                until not RenderFunctions
            end)
        end
    end))
end)


task.spawn(function()
    local whitelistsuccess, response = pcall(function() return RenderFunctions:CreateWhitelistTable() end)
    RenderFunctions.whitelistSuccess = whitelistsuccess
    RenderFunctions.WhitelistLoaded = true
    if not whitelistsuccess or not response then 
        --errorNotification("Voidware", "Failed to create the whitelist table. | "..(response or "Failed to Decode JSON"), 10)
    end
end)


getgenv().RenderFunctions = RenderFunctions
return RenderFunctions