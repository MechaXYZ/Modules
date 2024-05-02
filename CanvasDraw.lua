--[[
	================== CanvasDraw ===================
	
	Created by: Ethanthegrand (@Ethanthegrand14)
	
	Last updated: 6/11/2023
	Version: 3.4.1
	
	Learn how to use the module here: https://devforum.roblox.com/t/1624633
	Detailed API Documentation: https://devforum.roblox.com/t/2017699
	
	Copyright Â© 2022 - 2023 | CanvasDraw
]]
--[[
	============== QUICK API REFERENCE ==============

	CanvasDraw Functions:
	
	   - CanvasDraw.new() : Canvas
		  * Constructs and returns a canvas class/object
	
	   - CanvasDraw.GetImageData() : ImageData
		  * Reads the selected SaveObject's compressed ImageData and returns a readable ImageData class
		  
	   - CanvasDraw.CreateSaveObject() : Instance
		  * Returns a physical save object (a folder instance) containing compressed ImageData.
		  * This instance can be stored anywhere in your place and can be loaded into CanvasDraw.
		  * When 'InstantCreate' is set to false, CanvasDraw will slowly create this SaveObject to 
			avoid lag (Doing this is recommended for large images).
		  * The CanvasDraw image importer plugin uses this internally.
	
	Canvas Properties:
		
	   - OutputWarnings : boolean
		  * Determines whether any warning messages will appear in the output if something is out of place 
			or not working correctly according to the module.
	   
	   - AutoUpdate : boolean
		  * Determines whether the canvas will automatically update and render the pixels on the canvas every heartbeat.
		  * Set this property to false and call the Update() method to manually update and render the canvas.
	   
	   - Canvas.CanvasColour : Color3 [READ ONLY]
		  * The default background colour of the generated canvas.
	   
	   - Canvas.Resolution : Vector2 [READ ONLY]
		  * The current resolution of the canvas.
	   
	Canvas Drawing Methods:
		
	   - Canvas:FillCanvas()
		  * Replaces every pixel on the canvas with a colour
	   
	   - Canvas:ClearCanvas()
		  * Replaces every current pixel on the canvas with the canvas colour
	
	   - Canvas:FloodFill() : {...}
	   - Canvas:FloodFillXY()
		  * This function will fill an area of pixels on the canvas of the specific colour that your point is on.
		  * An array will also be returned containing all pixel points that were used to fill with.
		  * NOTE: This function is not very fast! Do not use for real-time engines
		 
	   - Canvas:DrawPixel() : Vector2
	   - Canvas:SetPixel()
		  * Places a pixel on the canvas
	  
	   - Canvas:DrawCircle() : {...}
	   - Canvas:DrawCircleXY()
		  * Draws a circle at a desired point with a set radius and colour.
	  
	   - Canvas:DrawRectangle() : {...}
	   - Canvas:DrawRectangleXY()
		  * Draws a simple rectangle shape from point A (top left) to point B (bottom right).
	  
	   - Canvas:DrawTriangle() : {...}
	   - Canvas:DrawTriangleXY()
		  * Draws a plain triangle from three points on the canvas.
	  
	   - Canvas:DrawLine() : {...}
	   - Canvas:DrawLineXY()
		  * Draws a simple pixel line from two points on the canvas.
	  
	   - Canvas:DrawImage()
	   - Canvas:DrawImageXY()
		  * Draws an image to the canvas from ImageData with optional scaling.
		  * Supports alpha blending when the 'TransparencyEnabled' parameter is set to true.
		 
	   - Canvas:DrawTexturedTriangle()
	   - Canvas:DrawTexturedTriangleXY()
		  * Draws a textured triangle at three points from a given ImageData and UV coordinates.
		  * UV coordinates range from a scale of 0 to 1 for each axis. 
			(0, 0 is top left, and 1, 1 is bottom right)
		  * Intended for 3D rendering or 2D textured polygons
		  * Supports transparency, but not alpha blending
		  * Has automatic 2D clipping
		  
	   - Canvas:DrawInterpolatedTriangle()
	   - Canvas:DrawInterpolatedTriangleXY()
		  * Draws a gradient-based triangle at three points with three colours.
		  * The triangle will interpolate between your three colours at the three points.
		  * Intended for 3D rendering
		  * Has automatic 2D clipping
		 
	   - Canvas:DrawDistortedImage()
	   - Canvas:DrawDistortedImageXY()
		  * Draws a four point textured quad/plane which can be scaled dynamically
		  * This can be used for 3D rendering or rotating, stretching, skewing or warping 2D images.
		  * Supports transparency, but not alpha blending
		 
	   - Canvas:DrawText()
	   - Canvas:DrawTextXY()
		  * Draw simple pixel text to the canvas. Great for debugging.
	
	 
	Canvas Fetch Methods:
	
	   - Canvas:GetPixel() : Color3
	   - Canvas:GetPixelXY() : Color3
		  * Returns the chosen pixel's colour (Color3)
	   
	   - Canvas:GetPixels(PointA: Vector2?, PointB: Vector2?) : {...}
		  * Returns all pixels ranging from PointA to PointB
	   
	   - Canvas:GetMousePoint() : Vector2? [CLIENT ONLY]
		  * If the client's mouse is within the canvas, a canvas point (Vector2) will be returned
			Otherwise, nothing will be returned (nil)
		  * This function is compatible with Guis and SurfaceGuis
	   
	   - Canvas:CreateImageData() : ImageData
		  * Returns an ImageData class/table from the canvas pixels from PointA to PointB or the whole canvas.
			
			
	ImageData Methods:
	
	   - ImageData:GetPixel() : Color3, number
	   - ImageData:GetPixelXY() : Color3, number
		  * Returns a tuple in order; the pixel's Color3 value and the pixel's alpha/transparency value (from 0 - 255)
	   
	   - ImageData:Tint()
		  * Interpolates the image's original pixels with a set colour
	   
	   - ImageData:SetPixel()
		  * Sets a specified pixel on the image to a given colour and alpha value
	   
	Other Canvas Methods:
	
	   - Canvas:DestroyCanvas()
		  * Destroys the canvas and all data related
		  
	   - Canvas:Update()
		  * Manually update/render the canvas (if Canvas.AutoUpdate is set to 'false')
	
	Canvas Events:
	
	   - Canvas.Updated(DeltaTime)
		  * The same as RunService.Heartbeat.
		  * This event is what CanvasDraw uses to update the canvas every frame 
			when the AutoUpdate property is set to true.
		  

]]

local Libraries = {}

local function require(what)
	return Libraries[what]
end

-- // libs

do
	-- // GuiPool
	
	do
		local module = {}
		local OFF_SCREEN = UDim2.fromOffset(0, math.huge)

		local TableInsert = table.insert
		local TableRemove = table.remove

		function module.new(original: GuiObject, initSize: number?)
			initSize = initSize or 50

			local Pool = {
				_Available = table.create(initSize),
				_Source = original:Clone(),
				_Index = initSize,
			}

			for i = 1, initSize do
				Pool._Available[i] = Pool._Source:Clone()
			end

			function Pool:Get()
				local Index = self._Index
				
				if Index > 0 then
					local object = self._Available[Index]
					TableRemove(self._Available, Index)
					self._Index -= 1
					return object
				end

				return self._Source:Clone()
			end

			function Pool:Return(object: GuiObject)
				object.Position = OFF_SCREEN
				TableInsert(self._Available, object)
				self._Index += 1
			end

			return Pool
		end

		Libraries.GuiPool = module
	end

	-- // FastCanvas

	do
		--[[

		FastCanvas is a modified version of Greedy/GradientCanvas by BoatBomber. 
		This version has the ability to remove blur artefacts from the original module and improve performance. 
		There are also some other minor additions to fit CanvasDraw's needs.

		Original module: https://github.com/boatbomber/GradientCanvas

		]]

		local module = {}

		local GuiPool = require("GuiPool")

		-- Micro optimizations
		local TableInsert = table.insert
		local TableClear = table.clear
		local TableCreate = table.create

		local Mclamp = math.clamp

		local UDim2FromScale = UDim2.fromScale
		local ColorSeqKeyPNew = ColorSequenceKeypoint.new
		local ColorSeqNew = ColorSequence.new

		function module.new(ResX: number, ResY: number, BlurEnabled: boolean)
			local Canvas = {
				_Active = 0,
				_ColumnFrames = {},
				_UpdatedColumns = {},

				--Threshold = 2,
				--LossyThreshold = 4,
			}

			local invX, invY = 1 / ResX, 1 / ResY
			--local dist = ResY * 0.03

			-- Generate initial grid of color data
			local Grid = TableCreate(ResX)
			
			for x = 1, ResX do
				Grid[x] = TableCreate(ResY, Color3.new(0.98, 1, 1))
			end

			Canvas._Grid = Grid

			-- Create a pool of Frame instances with Gradients
			do
				local Pixel = Instance.new("Frame")
				Pixel.BackgroundColor3 = Color3.new(1, 1, 1)
				Pixel.BorderSizePixel = 0
				Pixel.Name = "Pixel"
				local Gradient = Instance.new("UIGradient")
				Gradient.Name = "Gradient"
				Gradient.Rotation = 90
				Gradient.Parent = Pixel

				Canvas._Pool = GuiPool.new(Pixel, ResX)
				Pixel:Destroy()
			end

			-- Create GUIs
			local Gui = Instance.new("Frame")
			Gui.Name = "GradientCanvas"
			Gui.BackgroundTransparency = 1
			Gui.ClipsDescendants = true
			Gui.Size = UDim2.fromScale(1, 1)
			Gui.Position = UDim2.fromScale(0.5, 0.5)
			Gui.AnchorPoint = Vector2.new(0.5, 0.5)

			local AspectRatio = Instance.new("UIAspectRatioConstraint")
			AspectRatio.AspectRatio = ResX / ResY
			AspectRatio.Parent = Gui

			local Container = Instance.new("Folder")
			Container.Name = "FrameContainer"
			Container.Parent = Gui

			-- Define API
			local function createGradient(colorData, x, pixelStart, pixelCount)
				local Sequence = TableCreate(#colorData)

				for i, data in colorData do
					Sequence[i] = ColorSeqKeyPNew(Mclamp(data.p / pixelCount, 0, 1), data.c)
				end

				table.sort(Sequence, function(a, b)
					return a.Time < b.Time
				end)

				local Frame = Canvas._Pool:Get()
				Frame.Position = UDim2FromScale(invX * (x - 1), pixelStart * invY)
				Frame.Size = UDim2FromScale(invX, invY * pixelCount)
				Frame.Gradient.Color = ColorSeqNew(Sequence)
				Frame.Parent = Container

				if Canvas._ColumnFrames[x] == nil then
					Canvas._ColumnFrames[x] = { Frame }
				else
					TableInsert(Canvas._ColumnFrames[x], Frame)
				end

				Canvas._Active += 1
			end

			function Canvas:Destroy()
				TableClear(Canvas._Grid)
				TableClear(Canvas)
				Gui:Destroy()
			end

			function Canvas:SetParent(parent: Instance)
				Gui.Parent = parent
			end

			function Canvas:SetPixel(x: number, y: number, color: Color3)
				local Col = self._Grid[x]

				if Col[y] ~= color then
					Col[y] = color
					self._UpdatedColumns[x] = Col
				end
			end
			
			function Canvas:GetPixel(x: number, y: number)
				--local Col = self._Grid[x]
				--if not Col then
				--	return
				--end

				return self._Grid[x][y]
			end

			function Canvas:Clear(x: number?)
				if x then
					local column = self._ColumnFrames[x]
					if column == nil then return end

					for _, object in column do
						self._Pool:Return(object)
						self._Active -= 1
					end
					TableClear(column)
				else
					for _, object in Container:GetChildren() do
						self._Pool:Return(object)
					end
					self._Active = 0
					TableClear(self._ColumnFrames)
				end
			end

			function Canvas:Render()
				for x, column in self._UpdatedColumns do
					self:Clear(x)

					local colorCount, colorData = 1, {
						{ p = 0, c = column[1] },
					}

					local pixelStart, pixelCount = 0, 0
					--local pixelStart, lastPixel, pixelCount = 0, 0, 0
					
					local lastColor = column[1]

					-- Compress into gradients
					for y, color in column do
						pixelCount += 1

						-- Early exit to avoid the delta check on direct equality
						if lastColor == color then
							continue
						end

						--local delta = Util.DeltaRGB(lastColor, color)
						--if delta > self.Threshold then
						local offset = y - pixelStart - 1

						--if (delta > self.LossyThreshold) or (y-lastPixel > dist) then
						
						TableInsert(colorData, { p = offset - 0.08, c = lastColor })
						--colorCount += 1
						
						TableInsert(colorData, { p = offset, c = color })
						colorCount += 2

						lastColor = color
						--lastPixel = y

						if colorCount > 18 then
							TableInsert(colorData, { p = pixelCount, c = color })
							createGradient(colorData, x, pixelStart, pixelCount)

							pixelStart = y - 1
							pixelCount = 0
							colorCount = 1
							TableClear(colorData)
							colorData[1] = { p = 0, c = color }
						end
						--end
					end

					if pixelCount + pixelStart ~= ResY then
						pixelCount += 1
					end
					TableInsert(colorData, { p = pixelCount, c = lastColor })
					createGradient(colorData, x, pixelStart, pixelCount)
				end

				TableClear(self._UpdatedColumns)
			end

			return Canvas
		end

		Libraries.FastCanvas = module
	end

	-- // StringCompressor

	do
		-- Module by 1waffle1, optimized by boatbomber
		-- https://devforum.roblox.com/t/text-compression/163637

		local dictionary = {}
		do -- populate dictionary
			local length = 0
			for i = 32, 127 do
				if i ~= 34 and i ~= 92 then
					local c = string.char(i)
					dictionary[c], dictionary[length] = length, c
					length = length + 1
				end
			end
		end

		local escapemap = {}
		do -- Populate escape map
			for i = 1, 34 do
				i = ({ 34, 92, 127 })[i - 31] or i
				local c, e = string.char(i), string.char(i + 31)
				escapemap[c], escapemap[e] = e, c
			end
		end

		local function escape(s)
			return string.gsub(s, '[%c"\\]', function(c)
				return "\127" .. escapemap[c]
			end)
		end
		local function unescape(s)
			return string.gsub(s, "\127(.)", function(c)
				return escapemap[c]
			end)
		end

		local function copy(t)
			local new = {}
			for k, v in pairs(t) do
				new[k] = v
			end
			return new
		end

		local b93Cache = {}
		local function tobase93(n)
			local value = b93Cache[n]
			if value then
				return value
			end

			value = ""
			repeat
				local remainder = n % 93
				value = dictionary[remainder] .. value
				n = (n - remainder) / 93
			until n == 0

			b93Cache[n] = value
			return value
		end

		local b10Cache = {}
		local function tobase10(value)
			local n = b10Cache[value]
			if n then
				return n
			end

			n = 0
			for i = 1, #value do
				n = n + 93 ^ (i - 1) * dictionary[string.sub(value, -i, -i)]
			end

			b10Cache[value] = n
			return n
		end

		local function compress(text)
			local dictionaryCopy = copy(dictionary)
			local key, sequence, size = "", {}, #dictionaryCopy
			local width, spans, span = 1, {}, 0
			local function listkey(k)
				local value = tobase93(dictionaryCopy[k])
				local valueLength = #value
				if valueLength > width then
					width, span, spans[width] = valueLength, 0, span
				end
				table.insert(sequence, string.rep(" ", width - valueLength) .. value)
				span += 1
			end
			text = escape(text)
			for i = 1, #text do
				local c = string.sub(text, i, i)
				local new = key .. c
				if dictionaryCopy[new] then
					key = new
				else
					listkey(key)
					key = c
					size += 1
					dictionaryCopy[new], dictionaryCopy[size] = size, new
				end
			end
			listkey(key)
			spans[width] = span
			return table.concat(spans, ",") .. "|" .. table.concat(sequence)
		end

		local function decompress(text)
			local dictionaryCopy = copy(dictionary)
			local sequence, spans, content = {}, string.match(text, "(.-)|(.*)")
			local groups, start = {}, 1
			for span in string.gmatch(spans, "%d+") do
				local width = #groups + 1
				groups[width] = string.sub(content, start, start + span * width - 1)
				start = start + span * width
			end
			local previous

			for width, group in ipairs(groups) do
				for value in string.gmatch(group, string.rep(".", width)) do
					local entry = dictionaryCopy[tobase10(value)]
					if previous then
						if entry then
							table.insert(dictionaryCopy, previous .. string.sub(entry, 1, 1))
						else
							entry = previous .. string.sub(previous, 1, 1)
							table.insert(dictionaryCopy, entry)
						end
						table.insert(sequence, entry)
					else
						sequence[1] = entry
					end
					previous = entry
				end
			end

			return unescape(table.concat(sequence))
		end

		Libraries.StringCompressor = { Compress = compress, Decompress = decompress }    
	end

	-- // TextCharacters

	do
		local Characters = {
			-- Numbers
			["0"] = {
				{1,1,1},
				{1,0,1},
				{1,0,1},
				{1,0,1},
				{1,1,1},
			},
			["1"] = {
				{0,1,0},
				{0,1,0},
				{0,1,0},
				{0,1,0},
				{0,1,0},
			},
			["2"] = {
				{1,1,1},
				{0,0,1},
				{1,1,1},
				{1,0,0},
				{1,1,1},
			},
			["3"] = {
				{1,1,1},
				{0,0,1},
				{1,1,1},
				{0,0,1},
				{1,1,1},
			},
			["4"] = {
				{1,0,1},
				{1,0,1},
				{1,1,1},
				{0,0,1},
				{0,0,1},
			},
			["5"] = {
				{1,1,1},
				{1,0,0},
				{1,1,1},
				{0,0,1},
				{1,1,1},
			},
			["6"] = {
				{1,1,1},
				{1,0,0},
				{1,1,1},
				{1,0,1},
				{1,1,1},
			},
			["7"] = {
				{1,1,1},
				{0,0,1},
				{0,0,1},
				{0,0,1},
				{0,0,1},
			},
			["8"] = {
				{1,1,1},
				{1,0,1},
				{1,1,1},
				{1,0,1},
				{1,1,1},
			},
			["9"] = {
				{1,1,1},
				{1,0,1},
				{1,1,1},
				{0,0,1},
				{1,1,1},
			},
			
			-- Letters
			["a"] = {
				{1,1,1},
				{1,0,1},
				{1,1,1},
				{1,0,1},
				{1,0,1},
			},
			["b"] = {
				{1,1,0},
				{1,0,1},
				{1,1,1},
				{1,0,1},
				{1,1,1},
			},
			["c"] = {
				{1,1,1},
				{1,0,0},
				{1,0,0},
				{1,0,0},
				{1,1,1},
			},
			["d"] = {
				{1,1,0},
				{1,0,1},
				{1,0,1},
				{1,0,1},
				{1,1,1},
			},
			["e"] = {
				{1,1,1},
				{1,0,0},
				{1,1,1},
				{1,0,0},
				{1,1,1},
			},
			["f"] = {
				{1,1,1},
				{1,0,0},
				{1,1,1},
				{1,0,0},
				{1,0,0},
			},
			["g"] = {
				{1,1,1},
				{1,0,0},
				{1,0,1},
				{1,0,1},
				{1,1,1},
			},
			["h"] = {
				{1,0,1},
				{1,0,1},
				{1,1,1},
				{1,0,1},
				{1,0,1},
			},
			["i"] = {
				{1,1,1},
				{0,1,0},
				{0,1,0},
				{0,1,0},
				{1,1,1},
			},
			["j"] = {
				{0,0,1},
				{0,0,1},
				{0,0,1},
				{1,0,1},
				{1,1,1},
			},
			["k"] = {
				{1,0,1},
				{1,0,1},
				{1,1,0},
				{1,0,1},
				{1,0,1},
			},
			["l"] = {
				{1,0,0},
				{1,0,0},
				{1,0,0},
				{1,0,0},
				{1,1,1},
			},
			["m"] = {
				{1,0,1},
				{1,1,1},
				{1,1,1},
				{1,0,1},
				{1,0,1},
			},
			["n"] = {
				{1,1,1},
				{1,0,1},
				{1,0,1},
				{1,0,1},
				{1,0,1},
			},
			["o"] = {
				{1,1,1},
				{1,0,1},
				{1,0,1},
				{1,0,1},
				{1,1,1},
			},
			["p"] = {
				{1,1,1},
				{1,0,1},
				{1,1,1},
				{1,0,0},
				{1,0,0},
			},
			["q"] = {
				{1,1,1},
				{1,0,1},
				{1,0,1},
				{1,1,1},
				{0,1,0},
			},
			["r"] = {
				{1,1,1},
				{1,0,1},
				{1,1,0},
				{1,0,1},
				{1,0,1},
			},
			["s"] = {
				{1,1,1},
				{1,0,0},
				{1,1,1},
				{0,0,1},
				{1,1,1},
			},
			["t"] = {
				{1,1,1},
				{0,1,0},
				{0,1,0},
				{0,1,0},
				{0,1,0},
			},
			["u"] = {
				{1,0,1},
				{1,0,1},
				{1,0,1},
				{1,0,1},
				{1,1,1},
			},
			["v"] = {
				{1,0,1},
				{1,0,1},
				{1,0,1},
				{0,1,0},
				{0,1,0},
			},
			["w"] = {
				{1,0,1},
				{1,0,1},
				{1,1,1},
				{1,1,1},
				{1,0,1},
			},
			["x"] = {
				{1,0,1},
				{1,0,1},
				{0,1,0},
				{1,0,1},
				{1,0,1},
			},
			["y"] = {
				{1,0,1},
				{1,0,1},
				{1,1,1},
				{0,1,0},
				{0,1,0},
			},
			["z"] = {
				{1,1,1},
				{0,0,1},
				{0,1,0},
				{1,0,0},
				{1,1,1},
			},
			
			-- Symbols
			["!"] = {
				{0,1,0},
				{0,1,0},
				{0,1,0},
				{0,0,0},
				{0,1,0},
			},
			["@"] = {
				{1,1,0},
				{0,0,1},
				{1,1,1},
				{1,0,1},
				{1,1,0},
			},
			["#"] = {
				{1,0,1},
				{1,1,1},
				{1,0,1},
				{1,1,1},
				{1,0,1},
			},
			["$"] = {
				{0,1,0},
				{1,1,1},
				{1,0,0},
				{1,1,1},
				{0,1,0},
			},
			["%"] = {
				{1,0,1},
				{0,0,1},
				{0,1,0},
				{1,0,0},
				{1,0,1},
			},
			["^"] = {
				{0,1,0},
				{1,0,1},
				{0,0,0},
				{0,0,0},
				{0,0,0},
			},
			["&"] = {
				{0,1,0},
				{1,0,1},
				{0,1,0},
				{1,0,1},
				{1,1,1},
			},
			["*"] = {
				{1,0,1},
				{0,1,0},
				{1,0,1},
				{0,0,0},
				{0,0,0},
			},
			["("] = {
				{0,1,1},
				{1,0,0},
				{1,0,0},
				{1,0,0},
				{0,1,1},
			},
			[")"] = {
				{1,1,0},
				{0,0,1},
				{0,0,1},
				{0,0,1},
				{1,1,0},
			},
			["["] = {
				{1,1,1},
				{1,0,0},
				{1,0,0},
				{1,0,0},
				{1,1,1},
			},
			["]"] = {
				{1,1,1},
				{0,0,1},
				{0,0,1},
				{0,0,1},
				{1,1,1},
			},
			["{"] = {
				{0,1,1},
				{0,1,0},
				{1,1,0},
				{0,1,0},
				{0,1,1},
			},
			["}"] = {
				{1,1,0},
				{0,1,0},
				{0,1,1},
				{0,1,0},
				{1,1,0},
			},
			["-"] = {
				{0,0,0},
				{0,0,0},
				{1,1,1},
				{0,0,0},
				{0,0,0},
			},
			["_"] = {
				{0,0,0},
				{0,0,0},
				{0,0,0},
				{0,0,0},
				{1,1,1},
			},
			["+"] = {
				{0,0,0},
				{0,1,0},
				{1,1,1},
				{0,1,0},
				{0,0,0},
			},
			["="] = {
				{0,0,0},
				{1,1,1},
				{0,0,0},
				{1,1,1},
				{0,0,0},
			},
			["<"] = {
				{0,0,1},
				{0,1,0},
				{1,0,0},
				{0,1,0},
				{0,0,1},
			},
			[">"] = {
				{1,0,0},
				{0,1,0},
				{0,0,1},
				{0,1,0},
				{1,0,0},
			},
			["?"] = {
				{1,1,0},
				{0,0,1},
				{0,1,0},
				{0,0,0},
				{0,1,0},
			},
			["."] = {
				{0,0,0},
				{0,0,0},
				{0,0,0},
				{0,0,0},
				{0,1,0},
			},
			[","] = {
				{0,0,0},
				{0,0,0},
				{0,0,0},
				{0,1,0},
				{0,1,0},
			},
			["/"] = {
				{0,0,1},
				{0,1,0},
				{0,1,0},
				{0,1,0},
				{1,0,0},
			},
			["|"] = {
				{0,1,0},
				{0,1,0},
				{0,1,0},
				{0,1,0},
				{0,1,0},
			},
			[":"] = {
				{1,0,0},
				{0,0,0},
				{0,0,0},
				{0,0,0},
				{1,0,0},
			},
			[";"] = {
				{1,0,0},
				{0,0,0},
				{0,0,0},
				{1,0,0},
				{1,0,0},
			},
			['"'] = {
				{1,0,1},
				{1,0,1},
				{0,0,0},
				{0,0,0},
				{0,0,0},
			},
			["'"] = {
				{0,1,0},
				{0,1,0},
				{0,0,0},
				{0,0,0},
				{0,0,0},
			},
			["`"] = {
				{1,0,0},
				{0,1,0},
				{0,0,0},
				{0,0,0},
				{0,0,0},
			},
			["~"] = {
				{0,0,0},
				{1,1,0},
				{0,1,1},
				{0,0,0},
				{0,0,0},
			},
			[" "] = {
				{0,0,0},
				{0,0,0},
				{0,0,0},
				{0,0,0},
				{0,0,0},
			},
		}
		
		Libraries.TextCharacters = Characters		
	end

	-- // VectorFuncs

	do
		local Abs = math.abs

		function getNormalFromPartFace(part, normalId)
			return part.CFrame:VectorToWorldSpace(Vector3.FromNormalId(normalId))
		end
		
		function normalVectorToFace(part, normalVector)
			local normalIDs = {
				Enum.NormalId.Front,
				Enum.NormalId.Back,
				Enum.NormalId.Bottom,
				Enum.NormalId.Top,
				Enum.NormalId.Left,
				Enum.NormalId.Right
			}  
		
			for _, normalId in ipairs(normalIDs) do
				if getNormalFromPartFace(part, normalId):Dot(normalVector) > 0.999 then
					return normalId
				end
			end
		
			return nil -- None found within tolerance.
		end
		
		function getTopLeftCorners(part)
			local size = part.Size
			return {
				[Enum.NormalId.Front] = part.CFrame * CFrame.new(size.X/2, size.Y/2, -size.Z/2),
				[Enum.NormalId.Back] = part.CFrame * CFrame.new(-size.X/2, size.Y/2, size.Z/2),
				[Enum.NormalId.Right] = part.CFrame * CFrame.new(size.X/2, size.Y/2, size.Z/2),
				[Enum.NormalId.Left] = part.CFrame * CFrame.new(-size.X/2, size.Y/2, -size.Z/2),
				[Enum.NormalId.Bottom] = part.CFrame * CFrame.new(size.X/2, -size.Y/2, size.Z/2),
				[Enum.NormalId.Top] = part.CFrame * CFrame.new(-size.X/2, size.Y/2, size.Z/2)
			}
		end
		
		function getRotationComponents(offset) 
			local components = {offset:GetComponents()}
			table.remove(components, 1)
			table.remove(components, 2)
			table.remove(components, 3)
			
			return components
		end
		
		Libraries.VectorFuncs = {
			["normalVectorToFace"] = normalVectorToFace,
			["getTopLeftCorners"] = getTopLeftCorners
		}		
	end
end

local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

-- Modules
local GradientCanvas = require("FastCanvas") -- Credits to BoatBomber
local StringCompressor = require("StringCompressor") -- Credits to 1waffle1 and BoatBomber
local PixelTextCharacters = require("TextCharacters")
local VectorFuncs = require("VectorFuncs") -- Credits to Krystaltinan

local CanvasDraw = {}

-- These variables are only accessed by this module
local SaveObjectResolutionLimit = Vector2.new(256, 256) -- [DO NOT EDIT!] Roblox string value character limits
local CanvasResolutionLimit = Vector2.new(256, 256) -- Too many frames can cause rendering issues for roblox. So I think having this limit will help solve this problem for now.

-- Micro optimisations
local TableInsert = table.insert
local TableFind = table.find
local RoundN = math.round
local Vector2New = Vector2.new
local CeilN = math.ceil

--== BUILT-IN FUNCTIONS ==--

local function Swap(A, B)
	return B, A
end

local function GetRange(A, B)
	if A > B then
		return RoundN(A - B), -1
	else
		return RoundN(B - A), 1
	end
end

local function RoundPoint(Point)
	local X = RoundN(Point.X)
	local Y = RoundN(Point.Y)
	return Vector2New(X, Y)
end

local function PointToPixelIndex(Point, Resolution)
	return RoundN(Point.X) + (RoundN(Point.Y) - 1) * Resolution.X
end

local function XYToPixelIndex(X, Y, ResolutionX)
	return X + (Y - 1) * ResolutionX
end

local function Lerp(A, B, T)
	return A + (B - A) * T
end

local function LerpF(A, B, T) -- Assumes values range from 0 to 1
	return A + (B - A) * T
end

--== MODULE FUCNTIONS ==--

-- Canvas functions

function CanvasDraw.new(Frame: GuiObject, Resolution: Vector2?, CanvasColour: Color3?)
	local Canvas = {
		-- Modifyable properties/events
		OutputWarnings = true,
		AutoUpdate = true,

		-- Read only
		Resolution = Vector2New(100, 100),
		
		Updated = RunService.Heartbeat -- Event
	}


	--==<< Interal Functions >>==--

	local function OutputWarn(Message)
		if Canvas.OutputWarnings then
			warn("(!) CanvasDraw Module Warning: '" .. Message .. "'")
		end
	end

	--==<< Canvas Set-up >>==--

	-- Parameter defaults
	if CanvasColour then
		Canvas.CanvasColour = CanvasColour 
	else
		Canvas.CanvasColour = Frame.BackgroundColor3
	end

	if Resolution then
		if Resolution.X > CanvasResolutionLimit.X or Resolution.Y > CanvasResolutionLimit.Y then
			OutputWarn("A canvas cannot be built with a resolution larger than " .. CanvasResolutionLimit.X .. " x " .. CanvasResolutionLimit.Y .. ".")
			Resolution = CanvasResolutionLimit
		end
		Canvas.Resolution = Resolution
		Canvas.CurrentResX = Resolution.X
		Canvas.CurrentResY = Resolution.Y
	else
		Canvas.CurrentResX = 100
		Canvas.CurrentResY = 100
	end

	-- Create the canvas
	local InternalCanvas = GradientCanvas.new(Canvas.CurrentResX, Canvas.CurrentResY)
	InternalCanvas:SetParent(Frame)

	Canvas.AutoUpdateConnection = RunService.Heartbeat:Connect(function()
		if InternalCanvas and Canvas.AutoUpdate then
			InternalCanvas:Render()
		end
	end)

	Canvas.CurrentCanvasFrame = Frame

	for Y = 1, Canvas.CurrentResY do
		for X = 1, Canvas.CurrentResX do
			InternalCanvas:SetPixel(X, Y, Canvas.CanvasColour)
		end
	end

	InternalCanvas:Render()

	Canvas.InternalCanvas = InternalCanvas



	--============================================================================================================--
	--====  <<   Canvas API   >>   ================================================================================--
	--============================================================================================================--

	--==<< Canvas Methods >>==--

	function Canvas:DestroyCanvas()
		InternalCanvas:Destroy()
		self.InternalCanvas = nil
		self.CurrentCanvasFrame = nil
		self.AutoUpdateConnection:Disconnect()
	end

	function Canvas:FillCanvas(Colour: Color3)
		for Y = 1, self.CurrentResY do
			for X = 1, self.CurrentResX do
				InternalCanvas:SetPixel(X, Y, Colour)
			end
		end
	end

	function Canvas:ClearCanvas()
		self:FillCanvas(self.CanvasColour)
	end

	function Canvas:Update()
		InternalCanvas:Render()
	end


	--==<< Fetch Methods >>==--

	function Canvas:GetPixel(Point: Vector2): Color3
		Point = RoundPoint(Point)

		local X = Point.X
		local Y = Point.Y

		if X > 0 and Y > 0 and X <= self.CurrentResX and Y <= self.CurrentResY then
			return InternalCanvas:GetPixel(X, Y)
		end
	end

	function Canvas:GetPixelXY(X: number, Y: number): Color3
		return self.InternalCanvas:GetPixel(X, Y)
	end

	function Canvas:GetPixels(PointA: Vector2, PointB: Vector2): {}
		local PixelsArray = {}

		-- Get the all pixels between PointA and PointB
		if PointA and PointB then
			local DistX, FlipMultiplierX = GetRange(PointA.X, PointB.X)
			local DistY, FlipMultiplierY = GetRange(PointA.Y, PointB.Y)

			for Y = 0, DistY do
				for X = 0, DistX do
					local Point = Vector2New(PointA.X + X * FlipMultiplierX, PointA.Y + Y * FlipMultiplierY)
					local Pixel = self:GetPixel(Point)
					if Pixel then
						TableInsert(PixelsArray, Pixel)
					end
				end
			end
		else
			-- If there isn't any points in the paramaters, then return all pixels in the canvas
			for Y = 1, self.CurrentResX do
				for X = 1, self.CurrentResY do
					local Pixel = self:GetPixelXY(X, Y)
					if Pixel then
						TableInsert(PixelsArray, Pixel)
					end
				end
			end
		end

		return PixelsArray
	end

	function Canvas:GetMousePoint(): Vector2?
		if RunService:IsClient() then
			local MouseLocation = UserInputService:GetMouseLocation()
			local GuiInset = game.GuiService:GetGuiInset()

			local CanvasFrameSize = self.CurrentCanvasFrame.AbsoluteSize
			local GradientCanvasFrameSize = self.CurrentCanvasFrame.GradientCanvas.AbsoluteSize
			local CanvasPosition = self.CurrentCanvasFrame.AbsolutePosition

			local SurfaceGui = Frame:FindFirstAncestorOfClass("SurfaceGui")
			
			MouseLocation -= GuiInset

			if not SurfaceGui then
				-- Gui
				local MousePoint = MouseLocation - CanvasPosition

				local TransformedPoint = (MousePoint / GradientCanvasFrameSize) -- Normalised

				TransformedPoint *= self.Resolution -- Canvas space

				-- Make sure everything is aligned when the canvas is at different aspect ratios
				local RatioDifference = Vector2New(CanvasFrameSize.X / GradientCanvasFrameSize.X, CanvasFrameSize.Y / GradientCanvasFrameSize.Y) - Vector2New(1, 1)
				TransformedPoint -= (RatioDifference / 2) * self.Resolution
				
				local RoundX = math.ceil(TransformedPoint.X)
				local RoundY = math.ceil(TransformedPoint.Y)
				
				TransformedPoint = Vector2.new(RoundX, RoundY)

				-- If the point is within the canvas, return it.
				if TransformedPoint.X > 0 and TransformedPoint.Y > 0 and TransformedPoint.X <= self.CurrentResX and TransformedPoint.Y <= self.CurrentResY then
					return TransformedPoint
				end
			else
				-- SurfaceGui
				local Part = SurfaceGui.Adornee or SurfaceGui:FindFirstAncestorWhichIsA("BasePart") 
				local Camera = workspace.CurrentCamera

				local GradientCanvasFrame = Frame:FindFirstChild("GradientCanvas")

				if Part and GradientCanvasFrame then
					local Params = RaycastParams.new()
					Params.FilterType = Enum.RaycastFilterType.Include
					Params.FilterDescendantsInstances = {Part}

					local UnitRay = Camera:ViewportPointToRay(MouseLocation.X, MouseLocation.Y)

					local Result = workspace:Raycast(UnitRay.Origin, UnitRay.Direction * 1000, Params)

					if Result then
						local Normal = Result.Normal
						local IntersectionPos = Result.Position

						if VectorFuncs.normalVectorToFace(Part, Normal) ~= SurfaceGui.Face then
							return
						end

						-- Credits to @Krystaltinan for some of this code
						local hitCF = CFrame.lookAt(IntersectionPos, IntersectionPos + Normal)

						local topLeftCorners = VectorFuncs.getTopLeftCorners(Part)
						local topLeftCFrame = topLeftCorners[SurfaceGui.Face]

						local hitOffset = topLeftCFrame:ToObjectSpace(hitCF)

						local ScreenPos = Vector2.new(
							math.abs(hitOffset.X), 
							math.abs(hitOffset.Y)
						)

						-- Ensure the calculations work for all faces
						if SurfaceGui.Face == Enum.NormalId.Front or SurfaceGui.Face == Enum.NormalId.Back then
							ScreenPos -= Vector2.new(Part.Size.X / 2, Part.Size.Y / 2)
							ScreenPos /= Vector2.new(Part.Size.X, Part.Size.Y)
						else
							return -- Other faces don't seem to work for now
						end

						local PositionalOffset
						local AspectRatioDifference = GradientCanvasFrameSize / CanvasFrameSize
						local SurfaceGuiSizeDifference = SurfaceGui.AbsoluteSize / CanvasFrameSize

						--print(SurfaceGuiSizeDifference)

						local PosFixed = ScreenPos + Vector2.new(0.5, 0.5) -- Move origin to top left

						ScreenPos = PosFixed * SurfaceGui.AbsoluteSize -- Convert to SurfaceGui space

						ScreenPos -= CanvasPosition

						local TransformedPoint = (ScreenPos / GradientCanvasFrameSize) -- Normalised

						TransformedPoint *= self.Resolution -- Canvas space
						TransformedPoint += Vector2.new(0.5, 0.5)

						-- Make sure everything is aligned when the canvas is at different aspect ratios
						local RatioDifference = Vector2New(CanvasFrameSize.X / GradientCanvasFrameSize.X, CanvasFrameSize.Y / GradientCanvasFrameSize.Y) - Vector2New(1, 1)
						TransformedPoint -= (RatioDifference / 2) * self.Resolution

						TransformedPoint = RoundPoint(TransformedPoint)

						-- If the point is within the canvas, return it.
						if TransformedPoint.X > 0 and TransformedPoint.Y > 0 and TransformedPoint.X <= self.CurrentResX and TransformedPoint.Y <= self.CurrentResY then
							return TransformedPoint
						end

						return TransformedPoint
					end
				end	
			end
		else
			OutputWarn("Failed to get point from mouse (you cannot use this function on the server. Please call this function from a LocalScript).")
		end
	end


	--==<< Canvas Image Data Methods >>==--

	function Canvas:CreateImageDataFromCanvas(PointA: Vector2, PointB: Vector2): {}
		-- Set the default points to be the whole canvas corners
		if not PointA and not PointB then
			PointA = Vector2New(1, 1)
			PointB = self.Resolution
		end

		local ImageResolutionX = GetRange(PointA.X, PointB.X) + 1
		local ImageResolutionY = GetRange(PointA.Y, PointB.Y) + 1

		local ColoursData = self:GetPixels(PointA, PointB)
		local AlphasData = {}

		-- Canvas has no transparency. So all alpha values will be 255
		for i = 1, #ColoursData do
			TableInsert(AlphasData, 255)
		end

		return {ImageColours = ColoursData, ImageAlphas = AlphasData, ImageResolution = Vector2New(ImageResolutionX, ImageResolutionY)}
	end

	function Canvas:DrawImageXY(ImageData, X: number?, Y: number?, ScaleX: number?, ScaleY: number?, TransparencyEnabled: boolean?)
		X = X or 1
		Y = Y or 1
		ScaleX = ScaleX or 1
		ScaleY = ScaleY or 1

		local ImageResolutionX = ImageData.ImageResolution.X
		local ImageResolutionY = ImageData.ImageResolution.Y
		local ImageColours = ImageData.ImageColours
		local ImageAlphas = ImageData.ImageAlphas
		
		local ScaledImageResX = ImageResolutionX * ScaleX
		local ScaledImageResY = ImageResolutionY * ScaleY
		
		local StartX = 1
		local StartY = 1
		
		-- Clipping
		if X < 1 then
			StartX = -X + 2
		end
		if Y < 1 then
			StartY = -Y + 2
		end
		if X + ScaledImageResX - 1 > self.CurrentResX then
			ScaledImageResX -= (X + ScaledImageResX - 1) - self.CurrentResX
		end
		if Y + ScaledImageResY - 1 > self.CurrentResY then
			ScaledImageResY -= (Y + ScaledImageResY - 1) - self.CurrentResY
		end

		if not TransparencyEnabled then
			if ScaleX == 1 and ScaleY == 1 then
				-- Draw normal image with no transparency and no scale adjustments (most optimal)
				for ImgX = StartX, ScaledImageResX do
					local PlacementX = X + ImgX - 1

					for ImgY = StartY, ScaledImageResY do
						local PlacementY = Y + ImgY - 1

						local ImgPixelColour = ImageColours[ImgX + (ImgY - 1) * ImageResolutionX]
						InternalCanvas:SetPixel(PlacementX, PlacementY, ImgPixelColour)
					end
				end
			else
				-- Draw normal image with no transparency with scale adjustments (pretty optimal)
				for ImgX = StartX, ScaledImageResX do
					local SampleX = CeilN(ImgX / ScaleX)
					local PlacementX = X + ImgX - 1

					for ImgY = StartY, ScaledImageResY do
						local SampleY = CeilN(ImgY / ScaleY)
						local PlacementY = Y + ImgY - 1

						local ImgPixelColour = ImageColours[SampleX + (SampleY - 1) * ImageResolutionX]
						InternalCanvas:SetPixel(PlacementX, PlacementY, ImgPixelColour)
					end
				end
			end	
		else
			-- Draw image with transparency (more expensive)
			for ImgX = StartX, ScaledImageResX do
				local SampleX = CeilN(ImgX / ScaleX)
				local PlacementX = X + ImgX - 1

				for ImgY = StartY, ScaledImageResY do
					local SampleY = CeilN(ImgY / ScaleY)
					local PlacementY = Y + ImgY - 1

					local ImgPixelIndex = SampleX + (SampleY - 1) * ImageResolutionX
					local ImgPixelAlpha = ImageAlphas[ImgPixelIndex]

					if ImgPixelAlpha <= 1 then -- No need to do any calculations for completely transparent pixels
						continue
					end

					local BgColour = InternalCanvas:GetPixel(PlacementX, PlacementY)

					local ImgPixelColour = ImageColours[ImgPixelIndex]

					InternalCanvas:SetPixel(PlacementX, PlacementY, BgColour:Lerp(ImgPixelColour, ImgPixelAlpha / 255))
				end
			end
		end
	end
	
	function Canvas:DrawImage(ImageData, Point: Vector2?, Scale: Vector2, TransparencyEnabled: boolean?)
		Point = Point or Vector2.new(1, 1)
		Scale = Scale or Vector2.new(1, 1)
		
		Point = RoundPoint(Point)
		
		Canvas:DrawImageXY(ImageData, Point.X, Point.Y, Scale.X, Scale.Y, TransparencyEnabled)
	end


	---==<< Draw Methods >>==--

	function Canvas:ClearPixels(PixelPoints: table)
		self:FillPixels(PixelPoints, self.CanvasColour)
	end

	function Canvas:FillPixels(Points: table, Colour: Color3)
		for i, Point in pairs(Points) do
			self:DrawPixel(Point, Colour)
		end
	end
	
	function Canvas:FloodFill(Point: Vector2, Colour: Color3) -- Optimised by @Arevoir
		Point = RoundPoint(Point)

		local OriginColour = self:GetPixel(Point)
		local ReturnPointsArray = {}
		local seen = {} 
		
		local vectorUp = Vector2New(0, -1)
		local vectorRight = Vector2New(1, 0)
		local vectorDown = Vector2New(0, 1)
		local vectorLeft = Vector2New(-1, 0)

		local queue = { Point }
		
		local canvasWidth, canvasHeight = self.CurrentResX, self.CurrentResY

		while #queue > 0 do
			local currentPoint = table.remove(queue)

			local currentPointX = currentPoint.X
			local currentPointY = currentPoint.Y

			if currentPointX > 0 and currentPointY > 0 and currentPointX <= canvasWidth and currentPointY <= canvasHeight then
				local key = currentPointX + (currentPointY - 1) * canvasWidth --currentPointX .. "," .. currentPointY

				if not seen[key] then
					local pixelColour = self:GetPixelXY(currentPointX, currentPointY)
					if pixelColour == OriginColour then
						table.insert(ReturnPointsArray, currentPoint)
						InternalCanvas:SetPixel(currentPointX, currentPointY, Colour)

						seen[key] = true

						table.insert(queue, currentPoint + vectorUp)
						table.insert(queue, currentPoint + vectorDown)
						table.insert(queue, currentPoint + vectorLeft)
						table.insert(queue, currentPoint + vectorRight)
					end
				end
			end
		end

		return ReturnPointsArray
	end
	
	function Canvas:FloodFillXY(Point: Vector2, Colour: Color3)
		Point = RoundPoint(Point)

		local OriginColour = self:GetPixel(Point)
		local seen = {} 

		local vectorUp = Vector2New(0, -1)
		local vectorRight = Vector2New(1, 0)
		local vectorDown = Vector2New(0, 1)
		local vectorLeft = Vector2New(-1, 0)

		local queue = { Point }

		local canvasWidth, canvasHeight = self.CurrentResX, self.CurrentResY

		while #queue > 0 do
			local currentPoint = table.remove(queue)

			local currentPointX = currentPoint.X
			local currentPointY = currentPoint.Y

			if currentPointX > 0 and currentPointY > 0 and currentPointX <= canvasWidth and currentPointY <= canvasHeight then
				local key = currentPointX + (currentPointY - 1) * canvasWidth --currentPointX .. "," .. currentPointY

				if not seen[key] then
					local pixelColour = self:GetPixelXY(currentPointX, currentPointY)
					if pixelColour == OriginColour then
						InternalCanvas:SetPixel(currentPointX, currentPointY, Colour)

						seen[key] = true

						table.insert(queue, currentPoint + vectorUp)
						table.insert(queue, currentPoint + vectorDown)
						table.insert(queue, currentPoint + vectorLeft)
						table.insert(queue, currentPoint + vectorRight)
					end
				end
			end
		end
	end

	function Canvas:DrawPixel(Point: Vector2, Colour: Color3): Vector2
		local X = RoundN(Point.X)
		local Y = RoundN(Point.Y)

		if X > 0 and Y > 0 and X <= self.CurrentResX and Y <= self.CurrentResY then	
			InternalCanvas:SetPixel(X, Y, Colour)
			return Point	
		end
	end

	function Canvas:SetPixel(X: number, Y: number, Colour: Color3) -- A raw and performant method to draw pixels (much faster than `DrawPixel()`)
		InternalCanvas:SetPixel(X, Y, Colour)
	end

	function Canvas:DrawCircle(Point: Vector2, Radius: number, Colour: Color3, Fill: boolean): {}
		local X = RoundN(Point.X)
		local Y = RoundN(Point.Y)

		local PointsArray = {}

		-- Draw the circle
		local dx, dy, err = Radius, 0, 1 - Radius

		local function CreatePixelForCircle(DrawPoint)
			self:DrawPixel(DrawPoint, Colour)
			TableInsert(PointsArray, DrawPoint)
		end

		local function CreateLineForCircle(PointB, PointA)
			local Line = self:DrawRectangle(PointA, PointB, Colour, true)

			for i, Point in pairs(Line) do
				TableInsert(PointsArray, Point)
			end
		end

		if Fill or type(Fill) == "nil" then
			while dx >= dy do -- Filled circle
				CreateLineForCircle(Vector2New(X + dx, Y + dy), Vector2New(X - dx, Y + dy))
				CreateLineForCircle(Vector2New(X + dx, Y - dy), Vector2New(X - dx, Y - dy))
				CreateLineForCircle(Vector2New(X + dy, Y + dx), Vector2New(X - dy, Y + dx))
				CreateLineForCircle(Vector2New(X + dy, Y - dx), Vector2New(X - dy, Y - dx))

				dy = dy + 1
				if err < 0 then
					err = err + 2 * dy + 1
				else
					dx, err = dx - 1, err + 2 * (dy - dx) + 1
				end
			end
		else
			while dx >= dy do -- Circle outline
				CreatePixelForCircle(Vector2New(X + dx, Y + dy))
				CreatePixelForCircle(Vector2New(X - dx, Y + dy))
				CreatePixelForCircle(Vector2New(X + dx, Y - dy))
				CreatePixelForCircle(Vector2New(X - dx, Y - dy))
				CreatePixelForCircle(Vector2New(X + dy, Y + dx))
				CreatePixelForCircle(Vector2New(X - dy, Y + dx))
				CreatePixelForCircle(Vector2New(X + dy, Y - dx))
				CreatePixelForCircle(Vector2New(X - dy, Y - dx))

				dy = dy + 1
				if err < 0 then
					err = err + 2 * dy + 1
				else
					dx, err = dx - 1, err + 2 * (dy - dx) + 1
				end
			end
		end

		return PointsArray
	end

	function Canvas:DrawCircleXY(X: number, Y: number, Radius: number, Colour: Color3, Fill: boolean)
		if X + Radius > self.CurrentResX or Y + Radius > self.CurrentResY or X - Radius < 1 or Y - Radius < 1 then
			OutputWarn("CircleXY cannot exceed bounds! Drawing cancelled.")
			return
		end

		-- Draw the circle
		local dx, dy, err = Radius, 0, 1 - Radius

		local function CreatePixelForCircle(DrawX, DrawY)
			InternalCanvas:SetPixel(DrawX, DrawY, Colour)
		end

		local function CreateLineForCircle(EndX, StartX, Y)
			for DrawX = 0, EndX - StartX do
				InternalCanvas:SetPixel(StartX + DrawX, Y, Colour)
			end
		end

		if Fill or type(Fill) == "nil" then
			while dx >= dy do -- Filled circle
				CreateLineForCircle(X + dx, X - dx, Y + dy)
				CreateLineForCircle(X + dx, X - dx, Y - dy)
				CreateLineForCircle(X + dy, X - dy, Y + dx)
				CreateLineForCircle(X + dy, X - dy, Y - dx)

				dy = dy + 1
				if err < 0 then
					err = err + 2 * dy + 1
				else
					dx, err = dx - 1, err + 2 * (dy - dx) + 1
				end
			end
		else
			while dx >= dy do -- Circle outline
				CreatePixelForCircle(X + dx, Y + dy)
				CreatePixelForCircle(X - dx, Y + dy)
				CreatePixelForCircle(X + dx, Y - dy)
				CreatePixelForCircle(X - dx, Y - dy)
				CreatePixelForCircle(X + dy, Y + dx)
				CreatePixelForCircle(X - dy, Y + dx)
				CreatePixelForCircle(X + dy, Y - dx)
				CreatePixelForCircle(X - dy, Y - dx)

				dy = dy + 1
				if err < 0 then
					err = err + 2 * dy + 1
				else
					dx, err = dx - 1, err + 2 * (dy - dx) + 1
				end
			end
		end
	end

	function Canvas:DrawRectangle(PointA: Vector2, PointB: Vector2, Colour: Color3, Fill: boolean?)
		local ReturnPoints = {}
		
		PointA = RoundPoint(PointA)
		PointB = RoundPoint(PointB)
		
		local X1, Y1 = PointA.X, PointA.Y
		local X2, Y2 = PointB.X, PointB.Y
		
		if Y2 < Y1 then
			Y1, Y2 = Swap(Y1, Y2)
		end
		
		if X2 < X1 then
			X1, X2 = Swap(X1, X2)
		end

		-- Clipped coordinates
		local StartX = math.max(X1, 1)
		local StartY = math.max(Y1, 1)

		local RangeX = math.abs(X2 - X1) + X1
		local RangeY = math.abs(Y2 - Y1) + Y1

		RangeX = math.min(RangeX, self.CurrentResX)
		RangeY = math.min(RangeY, self.CurrentResY)
		
		local function InsertPoints(...)
			local PointsTable = {...}
			for i, Table in ipairs(PointsTable) do
				for i, Point in ipairs(Table) do
					table.insert(ReturnPoints, Point)
				end
			end
		end

		if Fill or type(Fill) == "nil" then
			-- Fill every pixel
			for PlotX = StartX, RangeX do
				for PlotY = StartY, RangeY do
					InternalCanvas:SetPixel(PlotX, PlotY, Colour)
					table.insert(ReturnPoints, Vector2.new(PlotX, PlotY))
				end
			end
		else
			-- Just draw the outlines (using solid rectangles)
			local TopLine = Canvas:DrawRectangle(Vector2New(X1, Y1), Vector2New(X2, Y1), Colour, true)
			local BottomLine = Canvas:DrawRectangle(Vector2New(X1, Y2), Vector2New(X2, Y2), Colour, true)

			local LeftLine = Canvas:DrawRectangle(Vector2New(X1, Y1), Vector2New(X1, Y2), Colour, true)
			local RightLine = Canvas:DrawRectangle(Vector2New(X2, Y1), Vector2New(X2, Y2), Colour, true)
			
			InsertPoints(TopLine, BottomLine, LeftLine, RightLine)
		end
		
		return ReturnPoints
	end

	function Canvas:DrawRectangleXY(X1: number, Y1: number, X2: number, Y2: number, Colour: Color3, Fill: boolean?)
		if Y2 < Y1 then
			Y1, Y2 = Swap(Y1, Y2)
		end

		if X2 < X1 then
			X1, X2 = Swap(X1, X2)
		end

		-- Clipped coordinates
		local StartX = math.max(X1, 1)
		local StartY = math.max(Y1, 1)

		local RangeX = math.abs(X2 - X1) + X1
		local RangeY = math.abs(Y2 - Y1) + Y1

		RangeX = math.min(RangeX, self.CurrentResX)
		RangeY = math.min(RangeY, self.CurrentResY)

		if Fill or type(Fill) == "nil" then
			-- Fill every pixel
			for PlotX = StartX, RangeX do
				for PlotY = StartY, RangeY do
					InternalCanvas:SetPixel(PlotX, PlotY, Colour)
				end
			end
		else
			-- Just draw the outlines (using solid rectangles)
			Canvas:DrawRectangleXY(X1, Y1, X2, Y1, Colour, true)
			Canvas:DrawRectangleXY(X1, Y2, X2, Y2, Colour, true)

			Canvas:DrawRectangleXY(X1, Y1, X1, Y2, Colour, true)
			Canvas:DrawRectangleXY(X2, Y1, X2, Y2, Colour, true)
		end
	end

	function Canvas:DrawTriangle(PointA: Vector2, PointB: Vector2, PointC: Vector2, Colour: Color3, Fill: boolean?): {}
		local ReturnPoints = {}

		if typeof(Fill) == "nil" or Fill == true then
			local X1 = PointA.X
			local X2 = PointB.X
			local X3 = PointC.X
			local Y1 = PointA.Y
			local Y2 = PointB.Y
			local Y3 = PointC.Y

			local CurrentY1 = Y1
			local CurrentY2 = Y2
			local CurrentY3 = Y3

			local CurrentX1 = X1
			local CurrentX2 = X2
			local CurrentX3 = X3

			-- Sort the vertices based on Y ascending
			if Y2 < Y1 then
				Y1, Y2 = Swap(Y1, Y2)
				X1, X2 = Swap(X1, X2)
			end

			if Y3 < Y1 then
				Y1, Y3 = Swap(Y1, Y3)
				X1, X3 = Swap(X1, X3)
			end

			if Y3 < Y2 then
				Y2, Y3 = Swap(Y2, Y3)
				X2, X3 = Swap(X2, X3)
			end

			local function PlotLine(StartX, EndX, Y)
				for X = 1, EndX - StartX do
					local Point = Vector2New(StartX + X, Y)
					self:DrawPixel(Point, Colour)

					TableInsert(ReturnPoints, Point)
				end
			end

			local function DrawBottomFlatTriangle(TriX1, TriY1, TriX2, TriY2, TriX3, TriY3) 
			--[[
				TriX1, TriY1 - Triangle top point
				TriX2, TriY2 - Triangle bottom left corner
				TriX3, TriY3 - Triangle bottom right corner
			]]
				local invslope1 = (TriX2 - TriX1) / (TriY2 - TriY1)
				local invslope2 = (TriX3 - TriX1) / (TriY3 - TriY1)

				local curx1 = TriX1
				local curx2 = TriX1

				for Y = 0, TriY3 - TriY1 do
					local DrawY = TriY1 + Y
					PlotLine(math.floor(curx1), math.floor(curx2), DrawY)
					curx1 += invslope1
					curx2 += invslope2
				end
			end

			local function DrawTopFlatTriangle(TriX1, TriY1, TriX2, TriY2, TriX3, TriY3)	
			--[[
				TriX1, TriY1 - Triangle top left corner
				TriX2, TriY2 - Triangle top right corner
				TriX3, TriY3 - Triangle bottom point
			]]
				local invslope1 = (TriX3 - TriX1) / (TriY3 - TriY1)
				local invslope2 = (TriX3 - TriX2) / (TriY3 - TriY2)

				local curx1 = TriX3
				local curx2 = TriX3

				for Y = 0, TriY3 - TriY1 do
					local DrawY = TriY3 - Y
					PlotLine(math.floor(curx1), math.floor(curx2), DrawY)
					curx1 -= invslope1
					curx2 -= invslope2
				end
			end

			local TriMidX = X1 + (Y2 - Y1) / (Y3 - Y1) * (X3 - X1)

			if TriMidX < X2 then
				DrawBottomFlatTriangle(X1, Y1, TriMidX, Y2, X2, Y2)
				DrawTopFlatTriangle(TriMidX, Y2, X2, Y2, X3, Y3)
			else
				DrawBottomFlatTriangle(X1, Y1, X2, Y2, TriMidX, Y2)
				DrawTopFlatTriangle(X2, Y2, TriMidX, Y2, X3, Y3)
			end
		end

		local LineA = self:DrawLine(PointA, PointB, Colour)
		local LineB = self:DrawLine(PointB, PointC, Colour)
		local LineC = self:DrawLine(PointC, PointA, Colour)

		for Point in pairs(LineA) do
			TableInsert(ReturnPoints, Point)
		end
		for Point in pairs(LineB) do
			TableInsert(ReturnPoints, Point)
		end
		for Point in pairs(LineC) do
			TableInsert(ReturnPoints, Point)
		end

		return ReturnPoints
	end


	function Canvas:DrawTriangleXY(X1: number, Y1: number, X2: number, Y2: number, X3: number, Y3: number, Colour: Color3, Fill: boolean?)
		if Fill or typeof(Fill) == "nil" then
			
			local function CheckPoint(X, Y)
				if X < 1 or Y < 1 or X > self.CurrentResX or Y > self.CurrentResY then
					return true
				end
			end

			if CheckPoint(X1, Y1) or CheckPoint(X2, Y2) or CheckPoint(X3, Y3) then
				OutputWarn("DrawTriangle (XY) Error: This drawing method doesn't have clipping (Points exceed bounds) Canceling...")
				return
			end
			
			-- Sort the vertices based on Y ascending
			if Y2 < Y1 then
				Y1, Y2 = Swap(Y1, Y2)
				X1, X2 = Swap(X1, X2)
			end

			if Y3 < Y1 then
				Y1, Y3 = Swap(Y1, Y3)
				X1, X3 = Swap(X1, X3)
			end

			if Y3 < Y2 then
				Y2, Y3 = Swap(Y2, Y3)
				X2, X3 = Swap(X2, X3)
			end
			
			local function PlotLine(StartX, EndX, Y)
				for X = 1, EndX - StartX do
					InternalCanvas:SetPixel(StartX + X, Y, Colour)
				end
			end

			local function DrawBottomFlatTriangle(TriX1, TriY1, TriX2, TriY2, TriX3, TriY3) 
			--[[
				TriX1, TriY1 - Triangle top point
				TriX2, TriY2 - Triangle bottom left corner
				TriX3, TriY3 - Triangle bottom right corner
			]]
				local invslope1 = (TriX2 - TriX1) / (TriY2 - TriY1)
				local invslope2 = (TriX3 - TriX1) / (TriY3 - TriY1)

				local curx1 = TriX1
				local curx2 = TriX1

				for Y = 0, TriY3 - TriY1 do
					local DrawY = TriY1 + Y
					PlotLine(math.floor(curx1), math.floor(curx2), DrawY)
					curx1 += invslope1
					curx2 += invslope2
				end
			end

			local function DrawTopFlatTriangle(TriX1, TriY1, TriX2, TriY2, TriX3, TriY3)	
			--[[
				TriX1, TriY1 - Triangle top left corner
				TriX2, TriY2 - Triangle top right corner
				TriX3, TriY3 - Triangle bottom point
			]]
				local invslope1 = (TriX3 - TriX1) / (TriY3 - TriY1)
				local invslope2 = (TriX3 - TriX2) / (TriY3 - TriY2)

				local curx1 = TriX3
				local curx2 = TriX3

				for Y = 0, TriY3 - TriY1 do
					local DrawY = TriY3 - Y
					PlotLine(math.floor(curx1), math.floor(curx2), DrawY)
					curx1 -= invslope1
					curx2 -= invslope2
				end
			end

			local TriMidX = X1 + (Y2 - Y1) / (Y3 - Y1) * (X3 - X1)

			if TriMidX < X2 then
				DrawBottomFlatTriangle(X1, Y1, TriMidX, Y2, X2, Y2)
				DrawTopFlatTriangle(TriMidX, Y2, X2, Y2, X3, Y3)
			else
				DrawBottomFlatTriangle(X1, Y1, X2, Y2, TriMidX, Y2)
				DrawTopFlatTriangle(X2, Y2, TriMidX, Y2, X3, Y3)
			end
		end

		self:DrawLineXY(X1, Y1, X2, Y2, Colour)
		self:DrawLineXY(X2, Y2, X3, Y3, Colour)
		self:DrawLineXY(X3, Y3, X1, Y1, Colour)
	end
	
	function Canvas:DrawTexturedTriangleXY(
		X1: number, Y1: number, X2: number, Y2: number, X3: number, Y3: number,
		U1: number, V1: number, U2: number, V2: number, U3: number, V3: number,
		ImageData, Brightness: number?
	)
		local TexResX, TexResY = ImageData.ImageResolution.X, ImageData.ImageResolution.Y

		if Y2 < Y1 then
			Y1, Y2 = Swap(Y1, Y2)
			X1, X2 = Swap(X1, X2)
			U1, U2 = Swap(U1, U2)
			V1, V2 = Swap(V1, V2)
		end

		if Y3 < Y1 then
			Y1, Y3 = Swap(Y1, Y3)
			X1, X3 = Swap(X1, X3)
			U1, U3 = Swap(U1, U3)
			V1, V3 = Swap(V1, V3)
		end

		if Y3 < Y2 then
			Y2, Y3 = Swap(Y2, Y3)
			X2, X3 = Swap(X2, X3)
			U2, U3 = Swap(U2, U3)
			V2, V3 = Swap(V2, V3)
		end

		if Y3 == Y1 then
			Y3 += 1
		end

		local dy1 = Y2 - Y1
		local dx1 = X2 - X1
		local dv1 = V2 - V1
		local du1 = U2 - U1

		local dy2 = Y3 - Y1
		local dx2 = X3 - X1
		local dv2 = V3 - V1
		local du2 = U3 - U1

		local TexU, TexV = 0, 0

		local dax_step, dbx_step = 0, 0
		local du1_step, dv1_step = 0, 0
		local du2_step, dv2_step = 0, 0

		dax_step = dx1 / math.abs(dy1)
		dbx_step = dx2 / math.abs(dy2)

		du1_step = du1 / math.abs(dy1)
		dv1_step = dv1 / math.abs(dy1)

		du2_step = du2 / math.abs(dy2)
		dv2_step = dv2 / math.abs(dy2)

		local function Plotline(ax, bx, tex_su, tex_eu, tex_sv, tex_ev, Y, IsBot)
			if ax > bx then
				ax, bx = Swap(ax, bx)
				tex_su, tex_eu = Swap(tex_su, tex_eu)
				tex_sv, tex_ev = Swap(tex_sv, tex_ev)
			end

			TexU, TexV = tex_su, tex_sv

			local Step = 1 / (bx - ax)
			local t = 0

			if Step > 10000 then
				Step = 10000
			end
			
			local ScanlineLength = math.ceil(bx - ax)
			
			-- Clip X right
			if bx > self.CurrentResX then
				ScanlineLength = self.CurrentResX - ax
			end
			
			-- Clip X left
			local StartOffsetX = 0
			
			if ax < 1 then	
				StartOffsetX = -(ax - 1)
				t = Step * StartOffsetX
			end

			for j = StartOffsetX, ScanlineLength do
				TexU = Lerp(tex_su, tex_eu, t)
				TexV = Lerp(tex_sv, tex_ev, t)

				local SampleX = math.min(math.floor(TexU * TexResX + 1), TexResX)
				local SampleY = math.min(math.floor(TexV * TexResY + 1), TexResY)

				local SampleColour, SampleAlpha = ImageData:GetPixelXY(SampleX, SampleY)

				if SampleColour and SampleAlpha > 1 then
					if not Brightness or Brightness == 1 then
						InternalCanvas:SetPixel(ax + j, Y, SampleColour)
					else
						local R, G, B = SampleColour.R, SampleColour.G, SampleColour.B
						R *= Brightness
						G *= Brightness
						B *= Brightness
						
						InternalCanvas:SetPixel(ax + j, Y, Color3.new(R, G, B))
					end
				end

				t += Step
			end

		end
		
		-- Clip Y top
		local YStart = 1
		
		if Y1 < 1 then
			YStart = 1 - Y1
		end
		
		-- Clip Y bottom
		local TopYDist = math.min(Y2 - Y1 - 1, self.CurrentResY - Y1)

		-- Draw top triangle
		for i = YStart, TopYDist do
			--task.wait(1)
			local ax = math.round(X1 + i * dax_step)
			local bx = math.round(X1 + i * dbx_step)

			-- Start values
			local tex_su = U1 + i * du1_step
			local tex_sv = V1 + i * dv1_step

			-- End values
			local tex_eu = U1 + i * du2_step
			local tex_ev = V1 + i * dv2_step

			-- Scan line
			Plotline(ax, bx, tex_su, tex_eu, tex_sv, tex_ev, Y1 + i)
		end

		dy1 = Y3 - Y2
		dx1 = X3 - X2
		dv1 = V3 - V2
		du1 = U3 - U2

		dax_step = dx1 / math.abs(dy1)
		dbx_step = dx2 / math.abs(dy2)

		du1_step, dv1_step = 0, 0

		du1_step = du1 / math.abs(dy1)
		dv1_step = dv1 / math.abs(dy1)

		-- Draw bottom triangle
		
		-- Clip Y bottom
		local BottomYDist = math.min(Y3 - 1 - Y2, self.CurrentResY - Y2)
		
		local YStart = 0

		if Y2 < 1 then
			YStart = 1 - Y2
		end
		
		for i = YStart, BottomYDist do
			i = Y2 + i
			--task.wait(1)
			local ax = math.round(X2 + (i - Y2) * dax_step)
			local bx = math.round(X1 + (i - Y1) * dbx_step)

			-- Start values
			local tex_su = U2 + (i - Y2) * du1_step
			local tex_sv = V2 + (i - Y2) * dv1_step

			-- End values
			local tex_eu = U1 + (i - Y1) * du2_step
			local tex_ev = V1 + (i - Y1) * dv2_step

			Plotline(ax, bx, tex_su, tex_eu, tex_sv, tex_ev, i, true)
		end
	end

	function Canvas:DrawTexturedTriangle(
		PointA: Vector2, PointB: Vector2, PointC: Vector2, 
		UV1: Vector2, UV2: Vector2, UV3: Vector2, 
		ImageData, Brightness: number?
	)
		
		-- Convert to intergers
		local X1, X2, X3 = math.ceil(PointA.X), math.ceil(PointB.X), math.ceil(PointC.X)
		local Y1, Y2, Y3 = math.ceil(PointA.Y), math.ceil(PointB.Y), math.ceil(PointC.Y)

		Canvas:DrawTexturedTriangleXY(
			X1, Y1, X2, Y2, X3, Y3,
			UV1.X, UV1.Y, UV2.X, UV2.Y, UV3.X, UV3.Y,
			ImageData, Brightness
		)
	end
	
	function Canvas:DrawDistortedImageXY(X1, Y1, X2, Y2, X3, Y3, X4, Y4, ImageData, Brightness: number?)
		Canvas:DrawTexturedTriangleXY(
			X1, Y1, X2, Y2, X3, Y3,
			0, 0, 0, 1, 1, 1,
			ImageData, Brightness
		)
		Canvas:DrawTexturedTriangleXY(
			X1, Y1, X4, Y4, X3, Y3,
			0, 0, 1, 0, 1, 1,
			ImageData, Brightness
		)
	end
	
	function Canvas:DrawDistortedImage(PointA, PointB, PointC, PointD, ImageData, Brightness: number?)
		Canvas:DrawDistortedImageXY(
			PointA.X, PointA.Y, PointB.X, PointB.Y, PointC.X, PointC.Y, PointD.X, PointD.Y,
			ImageData, Brightness
		)
	end

	function Canvas:DrawLine(PointA: Vector2, PointB: Vector2, Colour: Color3, Thickness: number?): {}
		local DrawnPointsArray = {}

		if not Thickness or Thickness < 1 then
			DrawnPointsArray = {PointA}

			local X1 = RoundN(PointA.X)
			local X2 = RoundN(PointB.X)
			local Y1 = RoundN(PointA.Y)
			local Y2 = RoundN(PointB.Y)

			local sx, sy, dx, dy

			if X1 < X2 then
				sx = 1
				dx = X2 - X1
			else
				sx = -1
				dx = X1 - X2
			end

			if Y1 < Y2 then
				sy = 1
				dy = Y2 - Y1
			else
				sy = -1
				dy = Y1 - Y2
			end

			local err, e2 = dx-dy, nil

			while not (X1 == X2 and Y1 == Y2) do
				e2 = err + err
				if e2 > -dy then
					err = err - dy
					X1  = X1 + sx
				end
				if e2 < dx then
					err = err + dx
					Y1 = Y1 + sy
				end

				local Point = Vector2New(X1, Y1)
				self:DrawPixel(Point, Colour)
				TableInsert(DrawnPointsArray, Point)
			end

			self:DrawPixel(PointA, Colour)

			return DrawnPointsArray
		else -- Custom polygon based thick line
			local X1, Y1 = PointA.X, PointA.Y
			local X2, Y2 = PointB.X, PointB.Y

			local RawRot = math.atan2(PointA.X - PointB.X, PointA.Y - PointB.Y) -- Use distances between each axis
			local Theta = RawRot

			local PiHalf = math.pi / 2

			-- Ensure we get an angle that measures up to 360 degrees (also avoids negative numbers)
			if RawRot < 0 then
				Theta = math.pi * 2 + RawRot
			end

			local Diameter = 1 + (Thickness * 2)
			local Rounder = (math.pi * 1.5) / Diameter

			Theta = math.round(Theta / Rounder) * Rounder -- Avoids strange behaviours for the triangle points

			-- Start polygon points
			local StartCornerX1 = math.floor(X1 + 0.5 + math.sin(Theta + PiHalf) * Thickness)
			local StartCornerY1 = math.floor(Y1 + 0.5 + math.cos(Theta + PiHalf) * Thickness)

			local StartCornerX2 = math.floor(X1 + 0.5 + math.sin(Theta - PiHalf) * Thickness)
			local StartCornerY2 = math.floor(Y1 + 0.5 + math.cos(Theta - PiHalf) * Thickness)

			-- End polygon points
			local EndCornerX1 = math.floor(X2 + 0.5 + math.sin(Theta + PiHalf) * Thickness)
			local EndCornerY1 = math.floor(Y2 + 0.5 + math.cos(Theta + PiHalf) * Thickness)

			local EndCornerX2 = math.floor(X2 + 0.5 + math.sin(Theta - PiHalf) * Thickness)
			local EndCornerY2 = math.floor(Y2 + 0.5 + math.cos(Theta - PiHalf) * Thickness)

			-- Draw 2 triangles at the start and end corners
			local TrianglePointsA = Canvas:DrawTriangle(Vector2New(StartCornerX1, StartCornerY1), Vector2New(StartCornerX2, StartCornerY2), Vector2New(EndCornerX1, EndCornerY1), Colour)
			local TrianglePointsB = Canvas:DrawTriangle(Vector2New(StartCornerX2, StartCornerY2), Vector2New(EndCornerX1, EndCornerY1), Vector2New(EndCornerX2, EndCornerY2), Colour)

			-- Draw rounded caps
			local CirclePointsA = Canvas:DrawCircle(PointA, Thickness, Colour)
			local CirclePointsB = Canvas:DrawCircle(PointB, Thickness, Colour)

			local function InsertContents(Table)
				for i, Item in ipairs(Table) do
					table.insert(DrawnPointsArray, Item)
				end
			end

			InsertContents(TrianglePointsA)
			InsertContents(TrianglePointsB)
			InsertContents(CirclePointsA)
			InsertContents(CirclePointsB)
		end

		return DrawnPointsArray
	end

	function Canvas:DrawLineXY(X1: number, Y1: number, X2: number, Y2: number, Colour: Color3, Thickness: number?)
		if not Thickness or Thickness < 1 then -- Bresenham line
			local sx, sy, dx, dy

			if X1 < X2 then
				sx = 1
				dx = X2 - X1
			else
				sx = -1
				dx = X1 - X2
			end

			if Y1 < Y2 then
				sy = 1
				dy = Y2 - Y1
			else
				sy = -1
				dy = Y1 - Y2
			end

			local err, e2 = dx-dy, nil

			while not(X1 == X2 and Y1 == Y2) do
				e2 = err + err
				if e2 > -dy then
					err = err - dy
					X1  = X1 + sx
				end
				if e2 < dx then
					err = err + dx
					Y1 = Y1 + sy
				end
				InternalCanvas:SetPixel(X1, Y1, Colour)
			end
		else -- Custom polygon based thick line
			local RawRot = math.atan2(X1 - X2, Y1 - Y2) -- Use distances between each axis
			local Theta = RawRot

			local PiHalf = math.pi / 2

			-- Ensure we get an angle that measures up to 360 degrees (also avoids negative numbers)
			if RawRot < 0 then
				Theta = math.pi * 2 + RawRot
			end

			local Diameter = 1 + (Thickness * 2)
			local Rounder = (math.pi * 1.5) / Diameter

			Theta = math.round(Theta / Rounder) * Rounder -- Avoids strange behaviours for the triangle points

			-- Start polygon points
			local StartCornerX1 = math.floor(X1 + 0.5 + math.sin(Theta + PiHalf) * Thickness)
			local StartCornerY1 = math.floor(Y1 + 0.5 + math.cos(Theta + PiHalf) * Thickness)

			local StartCornerX2 = math.floor(X1 + 0.5 + math.sin(Theta - PiHalf) * Thickness)
			local StartCornerY2 = math.floor(Y1 + 0.5 + math.cos(Theta - PiHalf) * Thickness)

			-- End polygon points
			local EndCornerX1 = math.floor(X2 + 0.5 + math.sin(Theta + PiHalf) * Thickness)
			local EndCornerY1 = math.floor(Y2 + 0.5 + math.cos(Theta + PiHalf) * Thickness)

			local EndCornerX2 = math.floor(X2 + 0.5 + math.sin(Theta - PiHalf) * Thickness)
			local EndCornerY2 = math.floor(Y2 + 0.5 + math.cos(Theta - PiHalf) * Thickness)

			-- Draw 2 triangles at the start and end corners
			Canvas:DrawTriangleXY(StartCornerX1, StartCornerY1, StartCornerX2, StartCornerY2, EndCornerX1, EndCornerY1, Colour)
			Canvas:DrawTriangleXY(StartCornerX2, StartCornerY2, EndCornerX1, EndCornerY1, EndCornerX2, EndCornerY2, Colour)

			-- Draw rounded caps
			Canvas:DrawCircleXY(X1, Y1, Thickness, Colour)
			Canvas:DrawCircleXY(X2, Y2, Thickness, Colour)
		end

	end

	function Canvas:DrawTextXY(Text: string, X: number, Y: number, Colour: Color3, Scale: number?, Wrap: boolean?, Spacing: number?)
		if not Spacing then
			Spacing = 1
		end

		if not Scale then
			Scale = 1
		end

		Scale = math.clamp(math.round(Scale), 1, 50)

		local CharWidth = 3 * Scale
		local CharHeight = 5 * Scale

		local TextLines = string.split(Text, "\n")

		for i, TextLine in pairs(TextLines) do
			local Characters = string.split(TextLine, "")

			local OffsetX = 0
			local OffsetY = (i - 1) * (CharHeight + Spacing)

			for i, Character in pairs(Characters) do
				local TextCharacter = PixelTextCharacters[Character:lower()]

				if TextCharacter then
					local StartOffsetX = -(math.min(1, X + OffsetX) - 1) + 1
					local StartOffsetY = -(math.min(1, Y + OffsetY) - 1) + 1
					
					if OffsetX + CharWidth > self.CurrentResX - X + 1 then
						if Wrap or type(Wrap) == "nil" then
							OffsetY += CharHeight + Spacing
							OffsetX = 0
						else
							break -- Don't write anymore text since it's outside the canvas
						end
					end

					for SampleY = StartOffsetY, CharHeight do
						local PlacementY = Y + SampleY - 1 + OffsetY
						SampleY = math.ceil(SampleY / Scale)

						if PlacementY - 1 >= self.CurrentResY then
							break
						end

						for SampleX = StartOffsetX, CharWidth do
							local PlacementX = X + SampleX - 1 + OffsetX
							
							if PlacementX > self.CurrentResX or PlacementX < 1 then
								continue
							end
							
							SampleX = math.ceil(SampleX / Scale)

							local Fill = TextCharacter[SampleY][SampleX]
							if Fill == 1 then
								InternalCanvas:SetPixel(PlacementX, PlacementY, Colour)
							end
						end
					end
				end

				OffsetX += CharWidth + Spacing
			end
		end
	end
	
	function Canvas:DrawText(Text: string, Point: Vector2, Colour: Color3, Scale: number?, Wrap: boolean?, Spacing: number?)
		Point = RoundPoint(Point)
		Canvas:DrawTextXY(Text, Point.X, Point.Y, Colour, Scale, Wrap, Spacing)
	end


	return Canvas
end


--============================================================================================================--
--====  <<   CanvasDraw Module ImageData API   >>   ===========================================================--
--============================================================================================================--

function CanvasDraw.GetImageData(SaveObject: Instance)
	local SaveDataImageColours = SaveObject:GetAttribute("ImageColours")
	local SaveDataImageAlphas = SaveObject:GetAttribute("ImageAlphas")
	local SaveDataImageResolution = SaveObject:GetAttribute("ImageResolution")

	-- Decompress the data
	local DecompressedSaveDataImageColours = StringCompressor.Decompress(SaveDataImageColours)
	local DecompressedSaveDataImageAlphas = StringCompressor.Decompress(SaveDataImageAlphas)

	-- Get a single pixel colour info form the data
	local PixelDataColoursString = string.split(DecompressedSaveDataImageColours, "S")
	local PixelDataAlphasString = string.split(DecompressedSaveDataImageAlphas, "S")

	local PixelColours = {}
	local OrigColours = {}
	local PixelAlphas = {}

	for i, PixelColourString in pairs(PixelDataColoursString) do
		local RGBValues = string.split(PixelColourString, ",")
		local PixelColour = Color3.fromRGB(table.unpack(RGBValues))

		local PixelAlpha = tonumber(PixelDataAlphasString[i])

		TableInsert(PixelColours, PixelColour)
		TableInsert(OrigColours, PixelColour)
		TableInsert(PixelAlphas, PixelAlpha)
	end

	-- Convert the SaveObject into image data
	local ImageData = {ImageColours = PixelColours, ImageAlphas = PixelAlphas, ImageResolution = SaveDataImageResolution}
	local ImageDataResX = SaveDataImageResolution.X
	local ImageDataResY = SaveDataImageResolution.Y


	--== ImageData methods ==--

	function ImageData:GetPixel(Point: Vector2): (Color3, number)
		local X, Y = math.ceil(Point.X), math.ceil(Point.Y)
		local Index = XYToPixelIndex(X, Y, ImageDataResX)

		return PixelColours[Index], PixelAlphas[Index]
	end

	function ImageData:GetPixelXY(X: number, Y: number): (Color3, number)
		local Index = XYToPixelIndex(X, Y, ImageDataResX)

		return PixelColours[Index], PixelAlphas[Index]
	end
	
	function ImageData:Tint(Colour: Color3, T: number)
		for i, OriginalColour in ipairs(OrigColours) do
			PixelColours[i] = OriginalColour:Lerp(Colour, T)
		end
	end
	
	function ImageData:SetPixel(X: number, Y: number, Colour: Color3, Alpha: number?)
		local Index = XYToPixelIndex(X, Y, ImageDataResX)
		
		PixelColours[Index] = Colour
		if Alpha then
			PixelAlphas[Index] = Alpha
		end
	end

	return ImageData
end

function CanvasDraw.CreateSaveObject(ImageData, InstantCreate: boolean?): Folder
	if ImageData.ImageResolution.X > SaveObjectResolutionLimit.X and ImageData.ImageResolution.Y > SaveObjectResolutionLimit.Y then
		warn([[Failed to create an image save object (ImageData too large). 
		Please try to keep the resolution of the image no higher than ']] .. SaveObjectResolutionLimit.X .. " x " .. SaveObjectResolutionLimit.Y .. "'.")
		return
	end

	local FastWaitCount = 0

	local function FastWait(Count) -- Avoid lag spikes
		if FastWaitCount >= Count then
			FastWaitCount = 0
			RunService.Heartbeat:Wait()
		else
			FastWaitCount += 1
		end
	end

	local function ConvertColoursToListString(Colours)
		local ColourData = {}
		local RgbStringFormat = "%d,%d,%d"

		for i, Colour in ipairs(Colours) do
			local R, G, B = RoundN(Colour.R * 255), RoundN(Colour.G * 255), RoundN(Colour.B * 255)
			TableInsert(ColourData, RgbStringFormat:format(R, G, B))

			if not InstantCreate then
				FastWait(4000)
			end
		end

		return table.concat(ColourData, "S")
	end

	local function ConvertAlphasToListString(Alphas)	
		local AlphasListString = table.concat(Alphas, "S")
		return AlphasListString
	end

	local ImageColoursString = ConvertColoursToListString(ImageData.ImageColours)
	local ImageAlphasString = ConvertAlphasToListString(ImageData.ImageAlphas)

	local CompressedImageColoursString = StringCompressor.Compress(ImageColoursString)
	local CompressedImageAlphasString = StringCompressor.Compress(ImageAlphasString)

	local NewSaveObject = Instance.new("Folder")
	NewSaveObject.Name = "NewSave"

	NewSaveObject:SetAttribute("ImageColours", CompressedImageColoursString)
	NewSaveObject:SetAttribute("ImageAlphas", CompressedImageAlphasString)
	NewSaveObject:SetAttribute("ImageResolution", ImageData.ImageResolution)

	return NewSaveObject
end


--== DEPRECATED FUNCTIONS/METHODS ==--

-- (!) Use ImageData:GetPixel() instead
function CanvasDraw.GetPixelFromImage(ImageData, Point: Vector2): (Color3, number)
	local PixelIndex = PointToPixelIndex(Point, ImageData.ImageResolution) -- Convert the point into an index for the array of colours

	local PixelColour = ImageData.ImageColours[PixelIndex]
	local PixelAlpha = ImageData.ImageAlphas[PixelIndex]

	return PixelColour, PixelAlpha
end

-- (!) Use ImageData:GetPixelXY() instead
function CanvasDraw.GetPixelFromImageXY(ImageData, X: number, Y: number): (Color3, number)
	local PixelIndex = XYToPixelIndex(X, Y, ImageData.ImageResolution.X) -- Convert the coordinates into an index for the array of colours

	local PixelColour = ImageData.ImageColours[PixelIndex]
	local PixelAlpha = ImageData.ImageAlphas[PixelIndex]

	return PixelColour, PixelAlpha
end

return CanvasDraw
