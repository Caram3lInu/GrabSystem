local cS = game:GetService("CollectionService")
local rS = game:GetService("ReplicatedStorage")
local rF = game:GetService("ReplicatedFirst")

local hum = game.Players.LocalPlayer.Character.Humanoid

local highlight = rF.Selection.Highlight
local clickdetect = rF.Selection.ClickDetector

local loaded = rS.Events.Effects.MapLoaded
local died

loaded.OnClientEvent:Connect(function()
	for _, part in ipairs(cS:GetTagged("canGrab")) do

		local h = highlight:Clone()
		h.Parent = part

		local c = clickdetect:Clone()
		c.Parent = part

		local enter = c.MouseHoverEnter:Connect(function()
			h.Enabled = true
		end)
		local leave = c.MouseHoverLeave:Connect(function()
			h.Enabled = false
		end)

		died = hum.Died:Connect(function()
			enter:Disconnect()
			leave:Disconnect()

			h:Destroy()
			c:Destroy()
			died:Disconnect()
		end)

	end
end)