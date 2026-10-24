if not game:IsLoaded() then
    game.Loaded:Wait()
end

repeat wait() until game.Players.LocalPlayer

queueonteleport = queueonteleport or queue_on_teleport
if queueonteleport then
    queueonteleport([[
		loadstring(game:HttpGet("https://raw.githubusercontent.com/grasserf/public/refs/heads/main/slapbattles/queuescript/candycorn.luau"))()
	]])
else
	game:GetService("StarterGui"):SetCore("SendNotification",{Title = "Error",Text = "You doesn't support queueonteleport",Icon = "rbxassetid://7733658504",Duration = 5})
end

local RJ = function()
    task.spawn(function()
    while wait() do
        local LocalPlayer = game.Players.LocalPlayer
        local httprequest = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request
        if not httprequest then
            LocalPlayer:Kick("Your executor cannot run rejoin script")
            return
        end
        local servers = {}
        local req = game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Desc&limit=100&excludeFullGames=true")
        local body = game:GetService("HttpService"):JSONDecode(req)
        if body and body.data then
            for _, v in next, body.data do
                if type(v) == "table" and tonumber(v.playing) and tonumber(v.maxPlayers) and v.playing < v.maxPlayers and v.id ~= game.JobId then
                    table.insert(servers, 1, v.id)
                end
            end
        end
        if #servers > 0 then
            game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, servers[math.random(1, #servers)], LocalPlayer)
        else
            wait()
        end
    end
    end)
end

if game.Players.LocalPlayer.PlayerScripts:FindFirstChild("VFXListener") then
    game.Players.LocalPlayer.PlayerScripts:FindFirstChild("VFXListener").Parent = game.ReplicatedStorage
end

spawn(function()
    while wait() do
        if not firetouchinterest then
            for _, v in pairs(game.Workspace.CandyCorns:GetChildren()) do
                v.CFrame = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame
            end
        else
            for _, v in pairs(game.Workspace.CandyCorns:GetChildren()) do     
                if game.Players.LocalPlayer.Character:FindFirstChild("Head") and v:FindFirstChildWhichIsA("TouchTransmitter") then
                    firetouchinterest(game.Players.LocalPlayer.Character.Head, v, 0)
                    firetouchinterest(game.Players.LocalPlayer.Character.Head, v, 1)
                end
            end
        end
    end
end)

wait()
RJ()
