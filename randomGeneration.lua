local sS = game:GetService("ServerStorage")
local rS = game:GetService("ReplicatedStorage")

local mapFolder = sS.MapGeneration:GetChildren()
local buildingFolder = sS.HouseFolder:GetChildren()
local grabbable = sS.Grabbable:GetChildren()
local bodies = sS.Bodies:GetChildren()

local previousModel = workspace.StartingZone

local createdBuildings = {}

local loaded = rS.Events.Effects.MapLoaded

local function generateItems(building)
	local spawnLocations  = building.Folder:GetChildren()

	for _, point in pairs(spawnLocations) do
		local rand = math.random(1,10)
		local randomObject
		if rand <= 5 then
			randomObject = grabbable[math.random(1,#grabbable)]:Clone()
			randomObject.Position = point.Position + Vector3.new(0,randomObject.Size.Y + 1,0)
		elseif rand == 6 then
			randomObject = bodies[math.random(1,#bodies)]:Clone()
			randomObject.PrimaryPart.CFrame = CFrame.new(point.Position + Vector3.new(0,randomObject.PrimaryPart.Size.Y*2,0))
		end
		if randomObject then
			randomObject.Parent = workspace.Grabbable
		end
	end
end

local function generateBuildings(newModel)
	local spawnLocations = newModel.SpawnLocations:GetChildren()
	
	local folder = Instance.new("Folder")
	folder.Name = "Buildings"
	folder.Parent = newModel
	
	for _, point in pairs(spawnLocations) do
		if math.random(1,6) == 1 then
			local randomBuilding = buildingFolder[math.random(1,#buildingFolder)]:Clone()
			randomBuilding:PivotTo(point.CFrame * CFrame.Angles(0,math.rad(math.random(0,360)),0))
			generateItems(randomBuilding)
			randomBuilding.Parent = folder
		end
	end
end

for i = 0,100 do
	local newModel = mapFolder[math.random(1,#mapFolder)]:Clone()
	newModel.PrimaryPart = newModel.Entrance
	newModel:PivotTo(previousModel.Exit.CFrame)
	generateBuildings(newModel)
	newModel.Parent = workspace.generatedMap
	previousModel = newModel
	task.wait(0.02)
end

print("Finished Loading")
loaded:FireAllClients()