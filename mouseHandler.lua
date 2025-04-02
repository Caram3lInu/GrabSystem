local uis = game:GetService("UserInputService")
local rs = game:GetService("RunService")
local rS = game:GetService("ReplicatedStorage")
local rF = game:GetService("ReplicatedFirst")

local player = game.Players.LocalPlayer
local hum = player.Character.Humanoid
local carrying = player:WaitForChild("isCarrying")
local currentPart = player:WaitForChild("currentPart")
local grab = rS.Events.Player.Grab
local drop = rS.Events.Player.Drop
local weld = rS.Events.Player.Weld
local unweld = rS.Events.Player.UnWeld
local canWeld = false
local camera = workspace.CurrentCamera
local mouse3DPosition
local raycastInstance
local params = RaycastParams.new()
params.FilterType = Enum.RaycastFilterType.Exclude
params.FilterDescendantsInstances = {game.Players}
local weldparams = OverlapParams.new()
weldparams.FilterType = Enum.RaycastFilterType.Include
weldparams.FilterDescendantsInstances = {workspace.canWeld}
local options = player.PlayerGui.Options.Frame
local grabF = options.Grab
local dropF = options.Drop
local weldF = options.Weld
local unweldF = options.Unweld

hum.Died:Connect(function()
	drop:FireServer()
end)

rs.PreRender:Connect(function()
	if carrying.Value ~= true and currentPart.Value == nil then
		local mouse2DPosition: Vector2 = uis:GetMouseLocation()
		local mouse3DRay: Ray = camera:ViewportPointToRay(mouse2DPosition.X,mouse2DPosition.Y,1)
		local raycastResult: RaycastResult = workspace:Raycast(mouse3DRay.Origin,mouse3DRay.Direction * 10, params)
		if raycastResult then
			mouse3DPosition = raycastResult.Position
			raycastInstance = raycastResult.Instance
			
			dropF.Visible, weldF.Visible = false, false
			local canGrab, welded = raycastInstance:HasTag("canGrab"), raycastInstance:HasTag("Welded")
			grabF.Visible = canGrab and not welded
			unweldF.Visible = welded
		else
			mouse3DPosition = (mouse3DRay.Origin + mouse3DRay.Direction * 30)
			raycastInstance = nil
		end
	else
		dropF.Visible, grabF.Visible, unweldF.Visible = true, false, false
		local part: Part = currentPart.Value
		canWeld = #workspace:GetPartBoundsInBox(part.CFrame, part.Size + Vector3.new(0.5, 0.5, 0.5), weldparams) > 0
		weldF.Visible = canWeld
	end
end)

uis.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		if carrying.Value ~= true and currentPart.Value == nil then
			grab:FireServer(mouse3DPosition,raycastInstance)
		else
			print("Drop")
			drop:FireServer()
		end
	elseif input.KeyCode == Enum.KeyCode.Z then
		if carrying.Value == true and currentPart.Value ~= nil then
			if currentPart.Value:HasTag("Welded") then return end
			weld:FireServer()
			return
		else
			unweld:FireServer(raycastInstance)
		end
	end
end)