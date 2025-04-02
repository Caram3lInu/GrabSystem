
function getratio(Vector: Vector3): number
	return math.max(Vector.X, Vector.Y, Vector.Z)
end



local rS = game:GetService("RunService")
local reS = game:GetService("ReplicatedStorage")
local cS = game:GetService("CollectionService")

local grab = reS.Events.Player.Grab
local drop = reS.Events.Player.Drop
local weld = reS.Events.Player.Weld
local unweld = reS.Events.Player.UnWeld
local lookvector = reS.Events.Player.LookVector

local weldparams = OverlapParams.new()
weldparams.FilterType = Enum.RaycastFilterType.Include
weldparams.FilterDescendantsInstances = {workspace.canWeld}

local grabTag = cS:GetTagged("canGrab")

local heartbeat
local lv = {}

local carry = {}

lookvector.OnServerEvent:Connect(function(player,lookVector)
	lv[player.Name] = lookVector
end)

grab.OnServerEvent:Connect(function(player,pos,part : BasePart)
	if part == nil then return end
	if not part:HasTag("canGrab") then return end
	if part:HasTag("Welded") == true then return end
	local carrying = player.isCarrying
	local currentPart = player.currentPart
	
	if carrying.Value ~= true and currentPart.Value == nil then
		carrying.Value = true
		currentPart.Value = part

		if part.Parent:IsA("Model") or script.Parent.Parent:IsA("Model") then
			for _, child in pairs(part.Parent:GetChildren()) do
				if child ~= part and child:IsA("Part") then
					child.Massless = true
					child.CollisionGroup = "Carrying"
				end
			end
		end

		part.Massless = true
		part.CollisionGroup = "Carrying"

		local att = Instance.new("Attachment")
		att.Name = "GrabAttachment"
		att.Parent =  part

		local aO = Instance.new("AlignOrientation")
		aO.Attachment0 = att
		aO.Mode = Enum.OrientationAlignmentMode.OneAttachment
		aO.Responsiveness = 100
		aO.Parent = part

		local aP = Instance.new("AlignPosition")
		aP.Attachment0 = att
		aP.Mode = Enum.PositionAlignmentMode.OneAttachment
		aP.Responsiveness = 100
		aP.MaxVelocity = 1000
		aP.Parent = part

		local head = player.Character.Head
		
		part:SetNetworkOwner(player)

		heartbeat = rS.Heartbeat:Connect(function(dT)
			local x,y,z = lv[player.Name].X,lv[player.Name].Y,lv[player.Name].Z
			aO.CFrame = CFrame.lookAt(part.Position,head.Position)
			aP.Position = (head.Position + Vector3.new(x,y,z) * (getratio(part.Size)+2))
		end)
		
		carry[player.UserId] = part.Destroying:Connect(function()
			currentPart.Value = nil
			carrying.Value = nil
			carry[player.UserId]:Disconnect()
		end)
	end
end)

drop.OnServerEvent:Connect(function(player)
	local carrying = player.isCarrying
	local currentPart = player.currentPart

	local part = currentPart.Value

	heartbeat:Disconnect()

	currentPart.Value = nil
	carrying.Value = nil

	part:SetNetworkOwner(nil)

	if part.Parent:IsA("Model") or script.Parent.Parent:IsA("Model") then
		for _, child in pairs(part.Parent:GetChildren()) do
			if child ~= part and child:IsA("Part") then
				child.Massless = false
				child.CollisionGroup = "Default"
			end
		end
	end

	part.Massless = false
	part.CollisionGroup = "Default"

	for _, item in pairs(part:GetChildren()) do
		if item.Name == "GrabAttachment" or item:IsA("AlignOrientation") or item:IsA("AlignPosition") then
			item:Destroy()
		end
	end
	
	if carry[player.UserId] ~= nil then
		carry[player.UserId]:Disconnect()
	end
	
end)

weld.OnServerEvent:Connect(function(player)
	local carrying = player.isCarrying
	local currentPart = player.currentPart
	if carrying.Value ~= true and currentPart.Value == nil then return end
	
	local part = currentPart.Value
	local detection = workspace:GetPartBoundsInBox(part.CFrame,Vector3.new(part.Size.X+1,part.Size.Y+1,part.Size.Z+1),weldparams)
	if detection[1] == nil then return end
	
	local welded = detection[1]
	if part:HasTag("Welded") == true then return end
	
	part:AddTag("Welded")

	local constraint = Instance.new("WeldConstraint")
	constraint.Part0 = welded
	constraint.Part1 = part
	constraint.Parent = part
	
	heartbeat:Disconnect()

	currentPart.Value = nil
	carrying.Value = nil

	part.Massless = false
	part.CollisionGroup = "Default"

	for _, item in pairs(part:GetChildren()) do
		if item:IsA("Attachment") or item:IsA("AlignOrientation") or item:IsA("AlignPosition") then
			item:Destroy()
		end
	end
end)

unweld.OnServerEvent:Connect(function(player,part)
	if part:HasTag("Welded") == false then return end
	
	for _, item in pairs(part:GetChildren()) do
		if item:IsA("WeldConstraint") then
			item:Destroy()
		end
	end
	
	part:RemoveTag("Welded")
end)

