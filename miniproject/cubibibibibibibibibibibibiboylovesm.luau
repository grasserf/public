if getgenv().ExecutedFarm then return end
getgenv().ExecutedFarm = true

local queueonteleport = queueonteleport or queue_on_teleport
if queueonteleport then
    queueonteleport([[
    loadstring(game:HttpGet('https://raw.githubusercontent.com/grasserf/public/refs/heads/main/miniproject/cubibibibibibibibibibibibiboylovesm.luau'))()
    ]])
end


if not game:IsLoaded() then
    game.Loaded:Wait()
end

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer.PlayerGui
local CoreGui = game:GetService("CoreGui")
local Debris = game:GetService("Debris")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera
local HttpService = game:GetService("HttpService")

local Stages = workspace.Map.Stages

local lp = LocalPlayer
local char = lp.Character or lp.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart", 15)
if not hrp then TeleportService:Teleport(game.PlaceId) end

local function canCarry(fossil)
	local pp = fossil:FindFirstChildWhichIsA("ProximityPrompt", true)
	if not pp or not pp.Enabled then
		return nil
	end
	local carriedBy = fossil:GetAttribute("CarriedByUserId")
	if carriedBy == "" or carriedBy == nil or carriedBy == 0 or carriedBy == lp.UserId then
		return pp
	end
	return nil
end

local function isServerBusy()
	local pending = lp:GetAttribute("PendingFossilName")
	return pending ~= nil and pending ~= ""
end

local function hasFossilsRemaining()
	for _, v in pairs(Stages:GetDescendants()) do
		if v:GetAttribute("IsFossil") and canCarry(v) then
			return true
		end
	end
	return false
end

local function idleFloat()
	local c = lp.Character or lp.CharacterAdded:Wait()
	if c then
		for _, v in pairs(c:GetChildren()) do
			if v:IsA("BasePart") then
				v.CanCollide = false
				v.Velocity = Vector3.new(0, 0, 0)
			end
		end
	end
end

local function resetCollision()
	local c = lp.Character or lp.CharacterAdded:Wait()
	if c then
		for _, v in pairs(c:GetChildren()) do
			if v:IsA("BasePart") then
				v.CanCollide = true
				v.Velocity = Vector3.new(0, 0, 0)
			end
		end
	end
end



local allowShop = false
spawn(function()
	local cdownshop = tick()
	repeat task.wait() until allowShop or tick() - cdownshop >= 60
	while wait() do
		local servers = {}
		local req = game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Desc&limit=100&excludeFullGames=true")
		local body = HttpService:JSONDecode(req)
		if body and body.data then
			for i, v in next, body.data do
				if type(v) == "table" and tonumber(v.playing) and tonumber(v.maxPlayers) and v.playing < v.maxPlayers and v.id ~= game.JobId then
					table.insert(servers, 1, v.id)
				end
			end
		end
		if #servers > 0 then
			TeleportService:TeleportToPlaceInstance(game.PlaceId, servers[math.random(1, #servers)], Players.LocalPlayer)
		else
			wait()
		end
	end
end)

while hasFossilsRemaining() do
	local bestFossil = nil
	local bestFossilValue = 0
	local pp = nil

	for _, v in pairs(Stages:GetDescendants()) do
		if v:GetAttribute("IsFossil") then
			local availablePP = canCarry(v)
			if availablePP then
				local frag = tonumber(v:GetAttribute("Fragments")) or 0
				if frag > bestFossilValue then
					bestFossilValue = frag
					bestFossil = v
					pp = availablePP
				end
			end
		end
	end

	if bestFossil and pp then
		repeat
			task.wait()
			workspace.CurrentCamera.CameraSubject = bestFossil
			idleFloat()
			fireproximityprompt(pp)
			char:PivotTo(bestFossil:GetPivot() * CFrame.new(0, 8, 0))
		until not pp or not pp.Parent or not pp.Enabled or tonumber(lp:GetAttribute("CarriedFossilCount")) >= 1

		local placePrompt = workspace.Map.FossilEvent.Station.ResearchTable.Table.PlaceAttachment.PlacePrompt

		repeat
			task.wait()
			char:PivotTo(workspace.Map.FossilEvent.Station.ResearchTable.Table:GetPivot() * CFrame.new(0, 0, -8))
			hrp.Velocity = Vector3.new(0, 0, 0)

			if not isServerBusy() then
				fireproximityprompt(placePrompt)
			end
			workspace.CurrentCamera.CameraSubject = workspace.Map.FossilEvent.Station.ResearchTable
			ReplicatedStorage.Remotes.Fossil:FireServer("Finish")
		until tonumber(lp:GetAttribute("CarriedFossilCount")) <= 0

		resetCollision()
		ReplicatedStorage.Remotes.Fossil:FireServer("Finish")
	end
end

char:PivotTo(workspace.Map.FossilEvent.Station.ResearchTable.Table:GetPivot() * CFrame.new(0, 0, 800000))
httprequest = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request
allowShop = true
