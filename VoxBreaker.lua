local VoxBreaker = {}
VoxBreaker.__index = VoxBreaker




--Module by @Bartokens
--@Bartokens on discord and  @bartoken on tiktok
--Find information here: https://devforum.roblox.com/t/voxbreaker-an-oop-voxel-destruction-module/2935099

--.----------------.  .----------------.  .----------------.  .----------------.  .----------------.  .----------------.  .----------------.  .----------------.  .----------------.  .----------------. 
--| .--------------. || .--------------. || .--------------. || .--------------. || .--------------. || .--------------. || .--------------. || .--------------. || .--------------. || .--------------. |
--| | ____   ____  | || |     ____     | || |  ____  ____  | || |   ______     | || |  _______     | || |  _________   | || |      __      | || |  ___  ____   | || |  _________   | || |  _______     | |
--| ||_  _| |_  _| | || |   .'    `.   | || | |_  _||_  _| | || |  |_   _ \    | || | |_   __ \    | || | |_   ___  |  | || |     /  \     | || | |_  ||_  _|  | || | |_   ___  |  | || | |_   __ \    | |
--| |  \ \   / /   | || |  /  .--.  \  | || |   \ \  / /   | || |    | |_) |   | || |   | |__) |   | || |   | |_  \_|  | || |    / /\ \    | || |   | |_/ /    | || |   | |_  \_|  | || |   | |__) |   | |
--| |   \ \ / /    | || |  | |    | |  | || |    > `' <    | || |    |  __'.   | || |   |  __ /    | || |   |  _|  _   | || |   / ____ \   | || |   |  __'.    | || |   |  _|  _   | || |   |  __ /    | |
--| |    \ ' /     | || |  \  `--'  /  | || |  _/ /'`\ \_  | || |   _| |__) |  | || |  _| |  \ \_  | || |  _| |___/ |  | || | _/ /    \ \_ | || |  _| |  \ \_  | || |  _| |___/ |  | || |  _| |  \ \_  | |
--| |     \_/      | || |   `.____.'   | || | |____||____| | || |  |_______/   | || | |____| |___| | || | |_________|  | || ||____|  |____|| || | |____||____| | || | |_________|  | || | |____| |___| | |
--| |              | || |              | || |              | || |              | || |              | || |              | || |              | || |              | || |              | || |              | |
--| '--------------' || '--------------' || '--------------' || '--------------' || '--------------' || '--------------' || '--------------' || '--------------' || '--------------' || '--------------' |
--'----------------'  '----------------'  '----------------'  '----------------'  '----------------'  '----------------'  '----------------'  '----------------'  '----------------'  '----------------' 


--[ DESCRIPTION ] ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- 

-- VoxBreaker is an OOP module for all your voxel destruction needs, or map building needs depending on how you want to use it.


-----[ DOCUMENTATION ]---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

----------| HOW TO USE |
--
--				1. Firstly, for any parts you want the module to work on, give them the attribute "Destroyable" and set it to true. 
--					The attribute name can be changed in the module settings.

--				2. Then, place the module where you want. I reccomend replicated storage, as the module works both on the client and on the server.
--				
--				3. On your script reference the module with: <local VoxBreaker = require(-wherever the module is stores-)>
--
--				4. Use the module however you want!


--	|FUNCTIONS|
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- The module currently has 4 functions, one of which is OOP based.

--		* VoxelizePart()
--			Repeatedly voxelizes a part until it meets the specified voxel size

--      		-Parameters: (Part : Part, MinimumVoxelSize : number, TimeToReset : number)
--					Part: Describes the part being voxelized
--					MinimumVoxelSize: Minimum possible size that Voxels can have. Module will try to match that size as accurately as possible. 5 by default.
--					TimeToReset: Time it takes in seconds to reset voxels back to normal. Will not reset if this is less than zero. 50 by default.

--				-Returns all voxels
--			

--			   -[EXAMPLE CODE] -- Prints all parts after voxelization
--				|	local VoxBreaker = require(game.ReplicatedStorage.VoxBreaker)						
--				|	local Part = workspace.Part
--				|	local Voxels = VoxBreaker:VoxelizePart(Part)
--				|	for i, v in pairs(Voxels) do
--				|		print(v)
--				|	end
--				|

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------	-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--		* CreateHitbox()
--			Creates one hitbox which divides any applicable parts that are touching it.


--      		-Parameters: (Size : Vector3, Cframe : CFrame , Shape : Enum.PartType , MinimumVoxelSize : number , TimeToReset : number)
--					Size: Size of the hitbox. (1,1,1) By default
--					Cframe: CFrame of the hitbox. (0,0,0) By default
--					Shape: Shape of the hitbox. Block by default.
--					MinimumVoxelSize: Minimum possible size that Voxels can have. Module will try to match that size as accurately as possible. 5 by default.
--					TimeToReset: Time it takes in seconds to reset voxels back to normal. Will not reset if this is less than zero. 50 by default.

--				-Tip: the larger the hitbox is, the larger I reccommend setting the MinimumVoxelSize. This helps tremendously with performance.

--				-Returns all voxels touching the hitbox
--			

--			   -[EXAMPLE CODE] --Destroys all voxels in hitbox.
--				|	local VoxBreaker = require(game.ReplicatedStorage.VoxBreaker)						
--				|	local Size = Vector3.new(10,10,10)
--				| 	local Cframe = CFrame.new(5,5,5)
--				| 	local Shape = Enum.PartType.Ball
--				| 	local MinimumSize = 8
--				|	local Seconds = 20
--				|
--				|	local Voxels = VoxBreaker:CreateHitbox(Size,Cframe,Shape,MinimumSize,Seconds)
--				|	for i, v in pairs(Voxels) do
--				|		v:Destroy()
--				|	end
--				|
--			   -[EXAMPLE CODE] -- Unanchors all voxels in hitbox.
--				|	local VoxBreaker = require(game.ReplicatedStorage.VoxBreaker)						
--				|
--				|	local Voxels = VoxBreaker:CreateHitbox()
--				|	for i, v in pairs(Voxels) do
--				|		v.Anchored = false
--				|	end
--				|

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--		* CreateMoveableHitbox() --OOP BASED
--			Creates a moveable hitbox that can be controlled manually or welded to a specified part.

--      		-Parameters: (MinimumVoxelSize : number, TimeToReset : number, Size : Vector3, Cframe : CFrame , Shape : Enum.PartType)
--					MinimumVoxelSize: Minimum possible size that Voxels can have. Module will try to match that size as accurately as possible. 5 by default.
--					TimeToReset: Time it takes in seconds to reset voxels back to normal. Will not reset if this is less than zero. 50 by default.
--					Size: Size of the hitbox. (1,1,1) By default
--					Cframe: CFrame of the hitbox. (0,0,0) By default
--					Shape: Shape of the hitbox. Block by default.

--				-Returns hitbox object

--				-Events:
--					.Touched(Parts)
--						Fires on every frame that the hitbox is touching applicable parts.
--						The parts argument contains the parts being touched.
--				-Functions:
--					:Start()
--						Starts the moveable hitbox.
--					:Stop()
--						Stops the moveable hitbox.
--					:Destroy()
--						Destroys the moveable hitbox.
--					:GetTouchingParts()
--						returns all parts touching the hitbox.
--					:WeldTo(Part)
--						Welds the hitbox to a specified part.
--					:UnWeld()
--						Unwelds the hitbox


--			   -[EXAMPLE CODE] --Creates a hitbox that is welded to a part and prints whenever touched
--				|
--				|	local VoxBreaker = require(game.ReplicatedStorage.VoxBreaker)						
--				|	local Size = Vector3.new(10,10,10)
--				| 	local Cframe = CFrame.new(5,5,5)
--				| 	local Shape = Enum.PartType.Ball
--				| 	local MinimumSize = 8
--				|	local Seconds = 20
--				|	local Projectile = Instance.new("Part")
--				| 	Projectile.Parent = workspace
--				|	
--				|	local Hitbox = VoxBreaker.CreateMoveableHitbox(MinimumSize,Seconds,Size,Cframe,Shape)
--				|	Hitbox:Start()
--				|	Hitbox:WeldTo(Projectile)
--				|	Hitbox.Touched:Connect(function()
--				|		print("Touched")
--				|	end)
--				|
--				|
--			   -[EXAMPLE CODE] -- Creates a hitbox that can be moved manually, and stops after 5 seconds
--				|
--				|	local VoxBreaker = require(game.ReplicatedStorage.VoxBreaker)						
--				|	local Size = Vector3.new(10,10,10)
--				| 	local Cframe = CFrame.new(5,5,5)
--				| 	local Shape = Enum.PartType.Ball
--				| 	local MinimumSize = 8
--				|	local Seconds = 20
--				|	local Projectile = Instance.new("Part")
--				| 	Projectile.Parent = workspace
--				|
--				|	local Hitbox = VoxBreaker.CreateMoveableHitbox(nil,MinimumSize,Seconds,Size,Cframe,Shape)
--				|	Hitbox:Start()
--				|	Hitbox.Part.Position = Vector3.new(10,10,10)
--				|	task.wait(2)
--				|	print(Hitbox:GetTouchingParts())
--				|	task.wait(3)
--				|	
--				|	Hitbox:Stop()
--				|

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


--		* CutInHalf() 
--			Cuts a specified part into two equal halves. Include parent if you want to change the parent of the parts.

--      		-Parameters: (Part : Part, Parent : Instance)
--					Part: Part to cut.
--					Parent: Optional parent that the parts will be parented to.

--				-Returns halves

--			   -[EXAMPLE CODE] --Split a part in two
--				|
--				|	local VoxBreaker = require(game.ReplicatedStorage.VoxBreaker)	
--				|	local Part = workspace.Part
--				|	VoxBreaker:CutInHalf(Part)
--				|
--				|





----[ RESOURCES ]------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local rs = game:GetService("RunService")

-----[ SETTINGS ]-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local TagName = "Destroyable" --Name of Attribute that module will check parts for
local RandomColors = false  -- Will make every part a random color. Set this to true if you want a visual representation of how the parts are being divided.
local Visualizer = false -- Will make hitboxes visible when set to true
local miniumCubeSize = 5 --Default Minimum possible size that divided cubes can be.
local voxelFolder = workspace --Where the voxels are stored. Workspace by default.
local AutoStartMoveable = false --Toggle this to true if you want your moveable hitboxes to activate automatically without having to use :Start()

-----[ LOCAL FUNCTIONS ]--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local partDestroyTimes = {}

function Destroy(part, time)
	if partDestroyTimes[part] then
		partDestroyTimes[part]:Disconnect()
	end
	partDestroyTimes[part] = game:GetService("RunService").Heartbeat:Connect(function()
		time = time - game:GetService("RunService").Heartbeat:Wait()
		if time <= 0 then
			part:Destroy()
			partDestroyTimes[part]:Disconnect()
			partDestroyTimes[part] = nil
		end
	end)
end


local function partCanSubdivide(part : Part) --Checks if part is rectangular.

	local Threshold = 1.5  -- How much of a difference there can be between the largest axis and the smallest axis 

	local largest = math.max(part.Size.X, part.Size.Y, part.Size.Z) --Largest Axis
	local smallest = math.min(part.Size.X,part.Size.Y, part.Size.Z) -- Smallest Axis

	if smallest == part.Size.X then 
		smallest = math.min(part.Size.Y, part.Size.Z)
	elseif smallest == part.Size.Y then
		smallest = math.min(part.Size.X, part.Size.Z)
	elseif smallest == part.Size.Z then
		smallest = math.min(part.Size.X, part.Size.Y)
	end

	return largest >= Threshold * smallest 
	--Returns true if part is rectangular. 
	--Part is rectangular if the largest axis is at least 1.5x bigger than the smallest axis

end

local function getLargestAxis(part : Part)  --Returns Largest Axis of Part size
	return math.max(part.Size.X, part.Size.Y, part.Size.Z)
end

local function CutPartinHalf(block : Part, TimeToReset : number, Parent : Instance) --Cuts part into two evenly shaped pieces.
	local partTable = {} --Table of parts to be returned
	local bipolarVectorSet = {} --Offset on where to place halves


	local X = block.Size.X
	local Y = block.Size.Y
	local Z = block.Size.Z

	if getLargestAxis(block) == X then --Changes offset vectors depending on what the largest axis is.
		X /= 2

		bipolarVectorSet = {
			Vector3.new(1,0,0),
			Vector3.new(-1,0,0),
		}

	elseif getLargestAxis(block) == Y then 
		Y/=2

		bipolarVectorSet = {
			Vector3.new(0,1,0),
			Vector3.new(0,-1,0),
		}

	elseif getLargestAxis(block) == Z then
		Z/=2

		bipolarVectorSet = {
			Vector3.new(0,0,1),
			Vector3.new(0,0,-1),
		}

	end

	local model 

	if block.Parent:IsA("Model") and block.Parent:GetAttribute("VoxelHolder") then
		model = block.Parent
	else
		model = Instance.new("Model")
		model.Parent = voxelFolder
		model:SetAttribute("VoxelHolder",true)
	end


	local halfSize = Vector3.new(X,Y,Z)

	for _, offsetVector in pairs(bipolarVectorSet) do

		local clone = block:Clone()
		if RandomColors then
			clone.Color = Color3.fromRGB(math.random(1,255),math.random(1,255),math.random(1,255))
		end


		clone.Parent = Parent or model
		clone.Size = halfSize
		clone.CFrame += block.CFrame:VectorToWorldSpace((halfSize / 2.0) * offsetVector)
		table.insert(partTable,clone)
	end

	if not TimeToReset or TimeToReset < 0 then
		block:Destroy()
	else
		if block:GetAttribute("Transparency") == nil then
			block:SetAttribute("Transparency",block.Transparency)
			block:SetAttribute("Collide",block.CanCollide)
			block:SetAttribute("Query",block.CanQuery)
		end
		block.Transparency = 1
		block.CanCollide = false
		block.CanQuery = false
		block:SetAttribute(TagName,false)
		
		for i,v in block:GetChildren() do
			task.spawn(function()
				if v:IsA("SurfaceGui") then
					local enabled = v.Enabled
					v.Enabled = false
					repeat task.wait()

					until model.Parent == nil
					v.Enabled = enabled
				elseif v:IsA("Decal") then
					local transparency = v.Transparency
					v.Transparency = 1
					repeat task.wait()

					until model.Parent == nil
					v.Transparency = transparency
				elseif v:IsA("Texture") then
					local transparency = v.Transparency
					v.Transparency = 1
					repeat task.wait()

					until model.Parent == nil
					v.Transparency = transparency					
				end
			end)
		end

		task.spawn(function()
			repeat task.wait()

			until model.Parent == nil
			task.wait(0.1)
			block.Transparency = block:GetAttribute("Transparency")
			block.CanQuery =  block:GetAttribute("Query")
			block.CanCollide = block:GetAttribute("Collide")
			block:SetAttribute(TagName,true)
		end)



	end
	return partTable -- Returns a table containing the two halves
end


local function DivideBlock(block : Part, MinimumVoxelSize : number, Parent : Instance, TimeToReset : number) --Divides part into evenly shaped cubes.
	--MinimumvVoxelSize Parameter is used to describe the minimum possible size that the parts can be divided. To avoid confusion, this is not the size that the parts will be divided into, but rather the minimum allowed
	--You CANNOT change the size of the resulting parts. They are dependent on the size of the original part.

	local partTable = {} -- Table of parts to be returned
	local minimum = MinimumVoxelSize or miniumCubeSize


	local reset = false


	if block.Size.X > minimum or block.Size.Y > minimum or block.Size.Z > minimum then


		local model 
		if block.Parent:IsA("Model") and block.Parent:GetAttribute("VoxelHolder") then
			model = block.Parent
		else
			model = Instance.new("Model")
			model.Parent = voxelFolder
			model:SetAttribute("VoxelHolder",true)
		end


		if TimeToReset and TimeToReset >= 0 then
			Destroy(model,TimeToReset)
		end



		local Threshold = 1.5  -- How much of a difference there can be between the largest axis and the smallest axis 

		local largest = math.max(block.Size.X, block.Size.Y, block.Size.Z) --Largest Axis
		local smallest = math.min(block.Size.X,block.Size.Y, block.Size.Z) -- Smallest Axis




		if smallest == block.Size.Y and smallest * Threshold <= largest then
			if block.Parent:IsA("Model") and block.Parent:GetAttribute("VoxelHolder") then
				model = block.Parent
			else
				model = Instance.new("Model")
				model.Parent = voxelFolder
				model:SetAttribute("VoxelHolder",true)
			end



			if TimeToReset and TimeToReset >= 0 then
				Destroy(model,TimeToReset)
			end

			if partCanSubdivide(block) then --If part is rectangular then it is cut in half, otherwise it is divided into cubes.
				partTable = CutPartinHalf(block,TimeToReset)
			else
				local bipolarVectorSet = {}

				local X = block.Size.X
				local Y = block.Size.Y
				local Z = block.Size.Z

					X /= 2
					Z /= 2
					bipolarVectorSet = { --Offset Vectors
						Vector3.new(-1,0,1),
						Vector3.new(1,0,-1),
						Vector3.new(1,0,1),
						Vector3.new(-1,0,-1),

					}


				local halfSize = Vector3.new(X,Y,Z)



				for _, offsetVector in pairs(bipolarVectorSet) do

					local clone = block:Clone()
					clone:SetAttribute("Voxel",true)
					if RandomColors then
						clone.Color = Color3.fromRGB(math.random(1,255),math.random(1,255),math.random(1,255))
					end

					clone.Parent = Parent or model
					clone.Size = halfSize
					clone.CFrame += block.CFrame:VectorToWorldSpace((halfSize / 2.0) * offsetVector)
					table.insert(partTable,clone)
				end


			end

		elseif smallest == block.Size.X and smallest * Threshold <= largest then
			if block.Parent:IsA("Model") and block.Parent:GetAttribute("VoxelHolder") then
				model = block.Parent
			else
				model = Instance.new("Model")
				model.Parent = voxelFolder
				model:SetAttribute("VoxelHolder",true)
			end



			if TimeToReset and TimeToReset >= 0 then
				Destroy(model,TimeToReset)
			end

			if partCanSubdivide(block) then --If part is rectangular then it is cut in half, otherwise it is divided into cubes.
				partTable = CutPartinHalf(block,TimeToReset)
			else
				local bipolarVectorSet = {}

				local X = block.Size.X
				local Y = block.Size.Y
				local Z = block.Size.Z

					Y /= 2
					Z /= 2
					bipolarVectorSet = { --Offset Vectors
						Vector3.new(0,-1,1),
						Vector3.new(0,1,1),
						Vector3.new(0,-1,-1),
						Vector3.new(0,1,-1),

					}


				local halfSize = Vector3.new(X,Y,Z)



				for _, offsetVector in pairs(bipolarVectorSet) do

					local clone = block:Clone()
					clone:SetAttribute("Voxel",true)
					if RandomColors then
						clone.Color = Color3.fromRGB(math.random(1,255),math.random(1,255),math.random(1,255))
					end

					clone.Parent = Parent or model
					clone.Size = halfSize
					clone.CFrame += block.CFrame:VectorToWorldSpace((halfSize / 2.0) * offsetVector)
					table.insert(partTable,clone)
				end


			end 
		elseif smallest == block.Size.Z and smallest * Threshold <= largest then
			if block.Parent:IsA("Model") and block.Parent:GetAttribute("VoxelHolder") then
				model = block.Parent
			else
				model = Instance.new("Model")
				model.Parent = voxelFolder
				model:SetAttribute("VoxelHolder",true)
			end



			if TimeToReset and TimeToReset >= 0 then
				Destroy(model,TimeToReset)
			end

			if partCanSubdivide(block) then --If part is rectangular then it is cut in half, otherwise it is divided into cubes.
				partTable = CutPartinHalf(block,TimeToReset)
			else
				local bipolarVectorSet = {}

				local X = block.Size.X
				local Y = block.Size.Y
				local Z = block.Size.Z

				X /= 2
				Y /= 2
				bipolarVectorSet = { --Offset Vectors
					Vector3.new(1,-1,0),
					Vector3.new(1,1,0),
					Vector3.new(-1,-1,0),
					Vector3.new(-1,1,0),

				}


				local halfSize = Vector3.new(X,Y,Z)



				for _, offsetVector in pairs(bipolarVectorSet) do

					local clone = block:Clone()
					clone:SetAttribute("Voxel",true)
					if RandomColors then
						clone.Color = Color3.fromRGB(math.random(1,255),math.random(1,255),math.random(1,255))
					end

					clone.Parent = Parent or model
					clone.Size = halfSize
					clone.CFrame += block.CFrame:VectorToWorldSpace((halfSize / 2.0) * offsetVector)
					table.insert(partTable,clone)
				end


			end 

		
		else
			
			
			if partCanSubdivide(block) then --If part is rectangular then it is cut in half, otherwise it is divided into cubes.
				partTable = CutPartinHalf(block,TimeToReset)
			else
				local bipolarVectorSet = { --Offset Vectors
					Vector3.new(1,1,1),
					Vector3.new(1,1,-1),
					Vector3.new(1,-1,1),
					Vector3.new(1,-1,-1),
					Vector3.new(-1,1,1),
					Vector3.new(-1,1,-1),
					Vector3.new(-1,-1,1),
					Vector3.new(-1,-1,-1),
				}

				local halfSize = block.Size / 2.0

				for _, offsetVector in pairs(bipolarVectorSet) do

					local clone = block:Clone()
					if RandomColors then
						clone.Color = Color3.fromRGB(math.random(1,255),math.random(1,255),math.random(1,255))
					end

					clone.Parent = Parent or model
					clone.Size = halfSize
					clone.CFrame += block.CFrame:VectorToWorldSpace((halfSize / 2.0) * offsetVector)
					table.insert(partTable,clone)
				end


			end

		end






		if not TimeToReset or TimeToReset < 0 then
			block:SetAttribute(TagName,false)
		block:Destroy()

		else
			

			if block:GetAttribute("Transparency") == nil then
				block:SetAttribute("Transparency",block.Transparency)
				block:SetAttribute("Collide",block.CanCollide)
				block:SetAttribute("Query",block.CanQuery)
			end



			block.Transparency = 1
			block.CanCollide = false
			block.CanQuery = false
			block:SetAttribute(TagName,false)
			
			for i,v in block:GetChildren() do
				task.spawn(function()
					if v:IsA("SurfaceGui") then
						local enabled = v.Enabled
						v.Enabled = false
						repeat task.wait()

						until model.Parent == nil
						v.Enabled = enabled
					elseif v:IsA("Decal") then
						local transparency = v.Transparency
						v.Transparency = 1
						repeat task.wait()

						until model.Parent == nil
						v.Transparency = transparency
					elseif v:IsA("Texture") then
						local transparency = v.Transparency
						v.Transparency = 1
						repeat task.wait()

						until model.Parent == nil
						v.Transparency = transparency					
					end
				end)
			end

			task.spawn(function()
				repeat task.wait()
				until model.Parent == nil
				task.wait(0.1)




				block.Transparency = block:GetAttribute("Transparency")
				block.CanQuery =  block:GetAttribute("Query")
				block.CanCollide = block:GetAttribute("Collide")

				block:SetAttribute(TagName,true)
			end)



		end
	elseif block.Parent:GetAttribute("VoxelHolder") == nil and block:GetAttribute("Voxel") == nil then

		if block:GetAttribute("Transparency") == nil then
			block:SetAttribute("Transparency",block.Transparency)
			block:SetAttribute("Collide",block.CanCollide)
			block:SetAttribute("Query",block.CanQuery)
		end
		local clone = block:Clone()
		clone.Parent = block.Parent	
		if TimeToReset and TimeToReset >= 0 then
			Destroy(clone,TimeToReset + 0.1)
		end



		if not TimeToReset or TimeToReset < 0 then
			block:SetAttribute(TagName,false)
			
		block:Destroy()
			
		else







			block.Transparency = 1
			block.CanCollide = false
			block.CanQuery = false
			block:SetAttribute(TagName,false)
			
			
			for i,v in block:GetChildren() do
				task.spawn(function()
					if v:IsA("SurfaceGui") then
						local enabled = v.Enabled
						v.Enabled = false
						task.wait(TimeToReset + 0.1)
						v.Enabled = enabled
					elseif v:IsA("Decal") then
						local transparency = v.Transparency
						v.Transparency = 1
						task.wait(TimeToReset + 0.1)
						v.Transparency = transparency
					elseif v:IsA("Texture") then
						local transparency = v.Transparency
						v.Transparency = 1
						task.wait(TimeToReset + 0.1)
						v.Transparency = transparency					
					end
				end)
			end
			

			task.spawn(function()
				task.wait(TimeToReset + 0.1)


				block.Transparency = block:GetAttribute("Transparency")
				block.CanQuery =  block:GetAttribute("Query")
				block.CanCollide = block:GetAttribute("Collide")
				block:SetAttribute(TagName,true)
			end)



		end

	end





	return partTable --Returns resulting parts
end

local function GetTouchingParts(part : Part) --Used to get all the parts within a part.
	local results = {}
	local touching = workspace:GetPartsInPart(part)
	for i,v in pairs(touching) do
		if v:IsA("Part") then
			if v:GetAttribute(TagName) == true then
				table.insert(results,v)
			end
		end
	end
	return results --Returns a table of all eligible parts touching the specified part
end

local function isTouching(partOne:Part,partTwo:Part) --Returns True if PartOne is touching PartTwo
	local check = false
	for i, v in pairs(GetTouchingParts(partOne)) do
		if v == partTwo then
			check = true
		end
	end
	return check

end

-----[ MODULE FUNCTIONS ]----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

function VoxBreaker:VoxelizePart(Part : Part, MinimumVoxelSize : number, TimeToReset : number) --Repeatedly voxelizes a part until it meets the specified voxel size
	local minimum = MinimumVoxelSize  or 5

	local parts = DivideBlock(Part,minimum,nil,TimeToReset)
	repeat

		for i, v in pairs(parts) do
			if v:IsDescendantOf(workspace) then
				local parts2 = DivideBlock(v,minimum)
				for _, p in  pairs(parts2) do
					table.insert(parts,p)
				end
			else
				table.remove(parts,i)
			end
		end

		local check = true
		for i, v in pairs(parts) do
			if math.floor(v.Size.X) > minimum or math.floor(v.Size.Y) > minimum or math.floor(v.Size.Z) > minimum then
				check = false
			end
		end
	until check == true
	return parts
end

function VoxBreaker:CreateHitbox(Size : Vector3, Cframe : CFrame , Shape : Enum.PartType , MinimumVoxelSize : number , TimeToReset : number) --Creates one hitbox which divides any applicable parts that are touching it. 
	--If the TimeToReset parameter is less than 0, then the parts will not reset.


	local DefaultSize = Vector3.new(1,1,1) -- Default Hitbox Size
	local DefaultShape = Enum.PartType.Block -- Default Shape of hitbox
	local DefaultTimeToReset = 50 --Default time in seconds it takes for divided parts to reset	


	local size = Size or DefaultSize
	local shape = Shape or DefaultShape
	local minimum = MinimumVoxelSize or miniumCubeSize
	local timetoreset = TimeToReset or DefaultTimeToReset



	local partTable = {} --Table of parts to be returned

	local part = Instance.new("Part") --Creating the hitbox

	Destroy(part,0.5) --Destroys hitbox in 0.5 seconds

	part.Size = Size or DefaultSize 
	part.CFrame = Cframe or CFrame.new(0,0,0)
	part.Anchored = true
	part.Transparency = 0.6
	if Shape then
		part.Shape = Shape
	end
	part.CanCollide = false
	part.Material = Enum.Material.Neon
	part.Color = Color3.fromRGB(255, 0, 0)

	if Visualizer then
		part.Parent = game.Workspace
	end

	repeat
		local touching = GetTouchingParts(part) --Initial check

		local check = true



		for i, v in pairs(touching) do
			if v:IsA("Part") and v:GetAttribute(TagName) then

				DivideBlock( v , minimum , nil , timetoreset)

			end
		end

		partTable = GetTouchingParts(part)

		for i, v in pairs(partTable) do
			if v:IsA("Part") and v:GetAttribute(TagName) then			
				if math.floor(v.Size.X) > minimum or math.floor(v.Size.Y) > minimum or math.floor(v.Size.Z) > minimum then
					check = false
				end
			else
				table.remove(partTable,i)
			end
		end

	until check == true
	return partTable --Returns all parts touching the hitbox



end

function VoxBreaker.CreateMoveableHitbox(MinimumVoxelSize : number, TimeToReset : number, Size : Vector3, Cframe : CFrame , Shape : Enum.PartType) --Creates a hitbox that can be moved or moves along with a specified part
	local self = {}

	--If WeldTo is specified, hitbox will move with specified part

	self.TouchEvent = Instance.new("BindableEvent") 
	self.Touched = self.TouchEvent.Event


	local DefaultSize = Vector3.new(1,1,1) -- Default Hitbox Size
	local DefaultShape = Enum.PartType.Block -- Default Shape of hitbox
	local DefaultTimeToReset = 50 --Default time in seconds it takes for divided parts to reset	



	local size = Size or DefaultSize
	local shape = Shape or  DefaultShape
	local minimum = MinimumVoxelSize or miniumCubeSize
	local timetoreset = TimeToReset or DefaultTimeToReset


	local part = Instance.new("Part") --Creating the hitbox
	if AutoStartMoveable then
		part:SetAttribute("Active",true)
	else
		part:SetAttribute("Active",false)		
	end

	self.Part = part


	part.Size = Size or DefaultSize 
	part.CFrame = Cframe or CFrame.new(0,0,0)
	part.Anchored = true
	part.Transparency = 0.6
	if Shape then
		part.Shape = Shape
	end
	part.CanCollide = false
	part.Material = Enum.Material.Neon
	part.Color = Color3.fromRGB(255, 0, 0)

	if Visualizer then
		part.Parent = game.Workspace
	end

	task.spawn(function()
		if rs:IsClient() then --If running on client, then runservice is used
			local lastTouching = {}
			local connection = rs.RenderStepped:Connect(function()
				if part:GetAttribute("Active") == true then
					local touching =  GetTouchingParts(part)
					if touching[1] ~= nil then

						local partTable = {}
						repeat
							local touching = GetTouchingParts(part) --Initial check

							local check = true



							for i, v in pairs(touching) do

								if v:IsA("Part") and v:GetAttribute(TagName) then

									DivideBlock( v , minimum , nil , timetoreset)

								end
							end

							partTable = GetTouchingParts(part)


							for i,v in pairs(lastTouching) do
								if table.find(partTable,v)  then
									table.remove(partTable,table.find(partTable,v))
								else
									table.remove(lastTouching,table.find(lastTouching,v))
								end
							end

							for i, v in pairs(partTable) do
								if v:IsA("Part") and v:GetAttribute(TagName) then			
									if math.floor(v.Size.X) > minimum or math.floor(v.Size.Y) > minimum or math.floor(v.Size.Z) > minimum then
										check = false
									end
								else
									table.remove(partTable,i)
								end
							end


						until check == true

						for i,v in partTable do
							if table.find(lastTouching,v) == nil then
								table.insert(lastTouching,v)
							else
								table.remove(partTable,table.find(partTable,v))
							end
						end




						if #partTable >= 1 then
							self.TouchEvent:Fire(partTable)
						end

					end					
				end
			end)
			local connection2 
			connection2 = part.AttributeChanged:Connect(function(attribute)
				if part:GetAttribute("Active") == false and part.Parent == nil then
					connection:Disconnect()
					connection2:Disconnect()
				end
			end)	
		else --If running on server, than a while loop is used.
			local connection = true
			local lastTouching = {}
			while connection do
				if part:GetAttribute("Active") == true then
					local touching =  GetTouchingParts(part)
					if touching[1] ~= nil then

						local partTable = {}
						repeat
							local touching = GetTouchingParts(part) --Initial check

							local check = true



							for i, v in pairs(touching) do

								if v:IsA("Part") and v:GetAttribute(TagName) then

									DivideBlock( v , minimum , nil , timetoreset)

								end
							end

							partTable = GetTouchingParts(part)


							for i,v in pairs(lastTouching) do
								if table.find(partTable,v)  then
									table.remove(partTable,table.find(partTable,v))
								else
									table.remove(lastTouching,table.find(lastTouching,v))
								end
							end

							for i, v in pairs(partTable) do
								if v:IsA("Part") and v:GetAttribute(TagName) then			
									if math.floor(v.Size.X) > minimum or math.floor(v.Size.Y) > minimum or math.floor(v.Size.Z) > minimum then
										check = false
									end
								else
									table.remove(partTable,i)
								end
							end


						until check == true

						for i,v in partTable do
							if table.find(lastTouching,v) == nil then
								table.insert(lastTouching,v)
							else
								table.remove(partTable,table.find(partTable,v))
							end
						end




						if #partTable >= 1 then
							self.TouchEvent:Fire(partTable)
						end

					end
				end
				task.wait()
			end
			local connection2 
			connection2 = part.AttributeChanged:Connect(function(attribute)
				if part:GetAttribute("Active") == false and part.Parent == nil then
					connection = false
					connection2:Disconnect()
				end
			end)
			
		end				
	end)

	return setmetatable(self,VoxBreaker)
end

function VoxBreaker:Start() -- Use to start moveable hitbox.
	self.Part:SetAttribute("Active",true)
end

function VoxBreaker:Stop() -- Use to stop moveable hitbox
	self.Part:SetAttribute("Active",false)
end

function VoxBreaker:Destroy() -- Use to destroy moveable hitbox
	self.Part:SetAttribute("Active",false)
	self.Part:Destroy()
end

function VoxBreaker:WeldTo(Part : Part) --welds the hitbox to a specified part
	task.spawn(function()
		local connection = rs.RenderStepped:Connect(function()
			if Part then
				self.Part.CFrame = Part.CFrame
			end

		end)
		local connection2 
		connection2 = self.Part.AttributeChanged:Connect(function(attribute)
			if self.Part:GetAttribute("Active") == false then
				connection:Disconnect()
				connection2:Disconnect()
			elseif self.Part:GetAttribute("Unweld") == true then
				connection:Disconnect()
				connection2:Disconnect()
			end
		end)
	end)
end

function VoxBreaker:UnWeld() -- Unwelds the hitbox
	self.Part:SetAttribute("Unweld",true)
	task.spawn(function()
		task.wait(0.1)
		self.Part:SetAttribute("Unweld",nil)
	end)

end

function VoxBreaker:GetTouchingParts(part : Part) -- Returns all parts touching moveable hitbox OR specified part
	if part then
		return GetTouchingParts(part)
	else
		return GetTouchingParts(self.Part)
	end
end

function VoxBreaker:CutInHalf(Part : Part, TimeToReset : number , Parent : Instance) -- Cuts a specified part into two pieces. Include parent if you want to change the parent of the parts.

	return CutPartinHalf(Part,TimeToReset,Parent) -- Returns halves
end

function VoxBreaker:Divide(part:Part,minimumVoxelSize:number,parent:Instance,timeToReset:number) -- Divides a part down once, into four pieces. Will not divide past minimum.
	return DivideBlock(part,minimumVoxelSize,parent,timeToReset)
end

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

return VoxBreaker
