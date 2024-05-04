--!native

--[[
	================== CanvasDraw ===================
	
	Created by: Ethanthegrand (@Ethanthegrand14)
	
	Last updated: 18/04/2024
	Version: 4.1.1.b - [Studio Only Beta Release]
	
	Learn how to use the module here: https://devforum.roblox.com/t/1624633
	Detailed API Documentation: https://devforum.roblox.com/t/2017699
	
	Copyright Â© 2022 - 2024 | CanvasDraw
]]

--[[
	============== QUICK API REFERENCE ==============

	CanvasDraw Functions:
	
	   - CanvasDraw.new(Frame, Resolution, CanvasColour?, Blur?) : Canvas
	      * Constructs and returns a canvas class/object
	
	   - CanvasDraw.GetImageData(SaveObject) : ImageData
	      * Reads the selected SaveObject's compressed ImageData and returns a readable ImageData class
	      
	   - CanvasDraw.GetImageDataFromTextureId(TextureId) : ImageData [YEILDS]
	      * Loads the selected roblox texture asset and returns an ImageData class.
	      * This method will yeild as it uses AssetService!
	      
	   - CanvasDraw.CreateBlankImageData(Width, Height) : ImageData
	      * Creates and returns a new blank ImageData object
	      
	   - CanvasDraw.CreateSaveObject(ImageData, InstantCreate) : Instance [YEILDS]?
	      * Returns a physical save object (a folder instance) containing compressed ImageData.
	      * This instance can be stored anywhere in your place and can be loaded into CanvasDraw.
		  * When 'InstantCreate' is set to false, CanvasDraw will slowly create this SaveObject to 
		    avoid lag (Doing this is recommended for large images).
		    This will also yeild the code execution.
		  * Intended for plugin use.
		  * NOTE: The provided ImageData has to be 256x256 or under!
		  
	   - CanvasDraw.CreateSaveObjectFromPixels(PixelArray, Width, Height, InstantCreate) : Instance [YEILDS]?
	      * Same as 'CanvasDraw.CreateSaveObject', but takes an array of RGBA values with
	        a width and height parameter.
	      * Intended for plugin use.
		  * NOTE: The width and height has to be 256x256 or under!
		  
	   - CanvasDraw.CompressImageData(ImageData) : CompressedImageData
	      * Returns a compressed image in the form of a very small table which takes advantage 
	        of string compression which reduces file size by a lot.
	      * Very useful with datastores.
	      * NOTE: Large images may cause slight lag spikes
	      
	   - CanvasDraw.DecompressImageData(CompressedImageData) : ImageData
	      * Decompresses the CompressedImageData table, and converts it back to
	        the original ImageData class.
	      * Very useful with datastores.
	      * NOTE: Large images may cause slight lag spikes
	
	Canvas Properties:
		
	   - OutputWarnings : boolean
	      * Determines whether any warning messages will appear in the output if something is out of place 
	        or not working correctly according to the module.
	      * Defaults to true.
	   
	   - AutoRender : boolean
	      * Determines whether the canvas will automatically update and render the pixels on the canvas every heartbeat.
	      * Set this property to false and call the Canvas:Render() method to manually update and render the canvas.
	      * Defaults to true.
	      
	   - Canvas.GridTransparency : number
	      * Sets the pixel grid overlay from 0 to 1.
	      * Set to 1 to disable/hide (Disabled by default)
	      
	   - Canvas.GridColour : Color3
	      * Sets the pixel grid colour (white by default)
	      
	   - Canvas.EditableImage : EditableImage
	      * The EditableImage instance that the canvas is currently using.
	   
	   - Canvas.CanvasColour : Color3 [READ ONLY]
	      * The default background colour of the generated canvas.
	   
	   - Canvas.Resolution : Vector2 [READ ONLY]
	      * The current resolution of the canvas.
	      
	   - FpsLimit : number [READ ONLY]
	      * The current FPS limit for the AutoRender property on the canvas.
	      * Defaults to 60.
	      * Use Canvas:SetFPSLimit() to change this!
	      
	  
	  
	Canvas Drawing Methods:
		
	   - Canvas:Fill(Colour)
	      * Replaces every pixel on the canvas with a colour
	   
	   - Canvas:Clear()
	      * Replaces every current pixel on the canvas with the canvas colour
	
	   - Canvas:FloodFill(Point, Colour) : {...}
	   - Canvas:FloodFillXY(X, Y, Colour)
	      * This function will fill an area of pixels on the canvas of the specific colour that your point is on.
	      * An array will also be returned containing all pixel points that were used to fill with.
	      * NOTE: This function is not very fast! Do not use for real-time engines
	     
	   - Canvas:DrawPixel(Point, Colour) : Vector2
	   - Canvas:SetPixel(X, Y, Colour)
	   - Canvas:SetRGB(X, Y, R, G, B)
	   - Canvas:SetAlpha(X, Y, Alpha)
	      * Places a pixel on the canvas
	  
	   - Canvas:DrawCircle(Point, Radius, Colour, Fill?) : {...}
	   - Canvas:DrawCircleXY(X, Y, Radius, Colour, Fill?)
	      * Draws a circle at a desired point with a set radius and colour.
	  
	   - Canvas:DrawRectangle(PointA, PointB, Colour, Fill?) : {...}
	   - Canvas:DrawRectangleXY(X1, Y1, X2, Y2, Colour, Fill?)
	      * Draws a simple rectangle shape from point A (top left) to point B (bottom right).
	  
	   - Canvas:DrawTriangle(PointA, PointB, PointC, Colour, Fill?) : {...}
	   - Canvas:DrawTriangleXY(X1, Y1, X2, Y2, X3, Y3, Colour, Fill?)
	      * Draws a plain triangle from three points on the canvas.
	  
	   - Canvas:DrawLine(PointA, PointB, Colour, Thickness?, RoundedCaps?) : {...}
	   - Canvas:DrawLineXY(X1, Y1, X2, Y2, Colour, Thickness?, RoundedCaps?)
	      * Draws a simple pixel line from two points on the canvas.
	  
	   - Canvas:DrawImage(ImageData, Point?, Scale?, TransparencyEnabled?)
	   - Canvas:DrawImageXY(ImageData, X?, Y?, ScaleX?, ScaleY?, TransparencyEnabled?)
	   
	      * Draws an image to the canvas from ImageData with optional scaling.
	      * Supports alpha blending when the 'TransparencyEnabled' parameter is set to true.
	     
	   - Canvas:DrawTexturedTriangle(PointA, PointB, PointC, UV1, UV2, UV3, ImageData, Brightness?)
	   - Canvas:DrawTexturedTriangleXY(X1, Y1, X2, Y2, X3, Y3, U1, V1, U2, V2, U3, V3, ImageData, Brightness?)
	      * Draws a textured triangle at three points from a given ImageData and UV coordinates.
	      * UV coordinates range from a scale of 0 to 1 for each axis. 
	        (0, 0 is top left, and 1, 1 is bottom right)
	      * Intended for 3D rendering or 2D textured polygons
	      * Supports transparency, but not alpha blending
	     
	   - Canvas:DrawDistortedImage(PointA, PointB, PointC, PointD, ImageData, Brightness?)
	   - Canvas:DrawDistortedImageXY(X1, Y1, X2, Y2, X3, Y3, X4, Y4, ImageData, Brightness?)
	      * Draws a four point textured quad/plane which can be scaled dynamically
	      * This can be used for 3D rendering or rotating, stretching, skewing or warping 2D images.
	      * Supports transparency, but not alpha blending
	     
	   - Canvas:DrawText(Text, Point, Colour, Scale?, Wrap?, Spacing?)
	   - Canvas:DrawTextXY(Text, X, Y, Colour, Scale?, Wrap?, Spacing?)
	      * Draw simple pixel text to the canvas. Great for debugging.
	
	 
	Canvas Fetch Methods:
	
	   - Canvas:GetPixel(Point) : Color3
	   - Canvas:GetPixelXY(X, Y) : Color3
	   - Canvas:GetRGB(X, Y) : number, number, number
	   - Canvas:GetAlpha(X, Y) : number
	      * Returns the chosen pixel from the canvas
	   
	   - Canvas:GetPixels(PointA?, PointB?) : {...}
	      * Returns all pixels ranging from PointA to PointB
	   
	   - Canvas:GetMousePoint() : Vector2? [CLIENT/PLUGIN ONLY]
	      * If the user's mouse is within the canvas, a canvas point (Vector2) will be returned
	        Otherwise, nothing will be returned (nil)
	      * NOTE: This function is only compatible with 'ScreenGui' and 'SurfaceGui'
	      
	   - Canvas:MouseIsOnTop() : boolean [CLIENT/PLUGIN ONLY]
	      * Returns true if the user's mouse is only on top of the canvas gui element.
	      * Will return false if the user's mouse in on top of a different gui element that's 
	        layered above the canvas, or if the mouse location is outside the canvas entirely.
	      * Useful for mouse inputs with canvas.
	   
	   - Canvas:CreateImageDataFromCanvas(PointA?, PointB?) : ImageData
	      * Returns an ImageData class/table from the canvas pixels from PointA to PointB or the whole canvas.
	        
	        
	ImageData Methods:
	
	   - ImageData:GetPixel(Point) : Color3, number
	   - ImageData:GetPixelXY(X, Y) : Color3, number
	   - ImageData:GetRGB(X, Y) : number, number, number
	   - ImageData:GetAlpha(X, Y) : number
	      * Returns a tuple in order; the pixel's colour and alpha value (from 0 - 1)
	   
	   - ImageData:Tint(Colour, T)
	      * Interpolates the image's original pixels with a set colour
	   
	   - ImageData:SetPixel(X, Y, Colour, Alpha?)
	   - ImageData:SetRGB(X, Y, R, G, B)
	   - ImageData:SetAlpha(X, Y, Alpha)
	      * Sets a specified pixel on the image to a given colour and alpha value
	      
	   - ImageData:Clone() : ImageData
	      * Returns a deep copy of an ImageData object
	      
	   
	Other Canvas Methods:
	
	   - Canvas:Destroy()
	      * Destroys the canvas and all data related
	      
	   - Canvas:Render()
	      * Manually update/render the canvas (if Canvas.AutoRender is set to 'false')
	
	Canvas Events:
	
	   - Canvas.OnRendered(DeltaTime)
	      * Fires whenever the canvas renders. By default, this is 60 FPS.
	      * Use 'Canvas:SetFPSLimit()'' to change the maximum framerate
	      * This event will never fire if 'Canvas.AutoRender' is set to false
	      

]]

local Libraries = {}

local function require(name)
    return Libraries[name]
end

do
    --!native

    --[[
        FastCanvas is a simple, but very fast and efficent 
        drawing canvas with per pixel methods via EditableImage.
        
        This module was designed to be intergrated with CanvasDraw. 
        A real-time roblox pixel graphics engine.

        Written by @Ethanthegrand14
        
        Created: 9/11/2023
        Last Updated: 30/12/2023
    ]]

    local FastCanvas = {}

    local Allowed

    function FastCanvas.new(Width: number, Height: number, CanvasParent: GuiObject, Blur: boolean?)
        
        local Canvas = {} -- The canvas object
        local Grid = table.create(Width * Height * 4, 1) -- Local pixel grid containing RGBA values

        local Origin = Vector2.zero
        local Resolution = Vector2.new(Width, Height)
        
        -- Local functions
        local function GetGridIndex(X, Y)
            return (X + (Y - 1) * Width) * 4 - 3
        end
        
        -- Create gui objects
        
        local CanvasFrame = Instance.new("ImageLabel")
        CanvasFrame.Name = "FastCanvas"
        CanvasFrame.BackgroundTransparency = 1
        CanvasFrame.ClipsDescendants = true
        CanvasFrame.Size = UDim2.fromScale(1, 1)
        CanvasFrame.Position = UDim2.fromScale(0.5, 0.5)
        CanvasFrame.AnchorPoint = Vector2.new(0.5, 0.5)
        
        if not Blur then
            CanvasFrame.ResampleMode = Enum.ResamplerMode.Pixelated
        end

        local AspectRatio = Instance.new("UIAspectRatioConstraint")
        AspectRatio.AspectRatio = Width / Height
        AspectRatio.Parent = CanvasFrame
        
        local EditableImage = Instance.new("EditableImage")
        EditableImage.Size = Resolution
        EditableImage.Parent = CanvasFrame
        
        CanvasFrame.Parent = CanvasParent
        
        -- Canvas properties
        
        Canvas.Image = EditableImage
        
        -- Pixel set methods
        
        function Canvas:SetColor3(X: number, Y: number, Colour: Color3)
            local Index = GetGridIndex(X, Y)
            Grid[Index] = Colour.R
            Grid[Index + 1] = Colour.G
            Grid[Index + 2] = Colour.B
        end
        
        function Canvas:SetRGB(X: number, Y: number, R: number, G: number, B: number)
            local Index = GetGridIndex(X, Y)
            Grid[Index] = R
            Grid[Index + 1] = G
            Grid[Index + 2] = B
        end
        
        function Canvas:SetAlpha(X: number, Y: number, Alpha: number)
            Grid[GetGridIndex(X, Y) + 3] = Alpha
        end
        
        -- Pixel fetch methods
        
        function Canvas:GetColor3(X: number, Y: number): Color3
            local Index = GetGridIndex(X, Y)
            
            return Color3.new(Grid[Index], Grid[Index + 1], Grid[Index + 2])
        end
        
        function Canvas:GetRGB(X: number, Y: number): (number, number, number)
            local Index = GetGridIndex(X, Y)
            
            return Grid[Index], Grid[Index + 1], Grid[Index + 2]
        end
        
        function Canvas:GetAlpha(X: number, Y: number): number
            local Index = GetGridIndex(X, Y)

            return Grid[Index + 3]
        end
        
        -- Canvas methods
        
        function Canvas:SetGrid(PixelArray)
            Grid = table.clone(PixelArray)
        end

        function Canvas:GetGrid()
            return table.clone(Grid)
        end
        
        function Canvas:Render()
            EditableImage:WritePixels(Origin, Resolution, Grid)
        end
        
        function Canvas:Destroy()
            Canvas = nil
            Grid = nil
            CanvasFrame:Destroy()
        end
        
        return Canvas
    end

    Libraries.FastCanvas = FastCanvas
end

do
    local Module = {}

    local function Lerp(A, B, T)
        return A + (B - A) * T
    end
    
    local function deepCopy(original)
        local copy = {}
        for k, v in pairs(original) do
            if type(v) == "table" then
                v = deepCopy(v)
            end
            copy[k] = v
        end
        return copy
    end
    
    function Module.new(ImageDataResX, ImageDataResY, PixelArray)
        local ImageData = {
            ImagePixels = PixelArray, 
            ImageResolution = Vector2.new(ImageDataResX, ImageDataResY),
            Width = ImageDataResX,
            Height = ImageDataResY,
        }
    
        local function GetIndex(X, Y)
            return (X + (Y - 1) * ImageDataResX) * 4 - 3
        end
    
        --== ImageData methods ==--
    
        function ImageData:GetPixel(Point: Vector2): (Color3, number)
            local X, Y = math.floor(Point.X), math.floor(Point.Y)
            local Array = self.ImagePixels
            local Index = GetIndex(X, Y)
    
            return Color3.new(Array[Index], Array[Index + 1], Array[Index + 2]), Array[Index + 3]
        end
    
        function ImageData:GetPixelXY(X: number, Y: number): (Color3, number)
            local Array = self.ImagePixels
            local Index = GetIndex(X, Y)
    
            return Color3.new(Array[Index], Array[Index + 1], Array[Index + 2]), Array[Index + 3]
        end
    
        function ImageData:GetRGB(X: number, Y: number): (number, number, number)
            local Array = self.ImagePixels
            local Index = GetIndex(X, Y)
    
            return Array[Index], Array[Index + 1], Array[Index + 2]
        end
    
        function ImageData:GetAlpha(X: number, Y: number): number
            return self.ImagePixels[GetIndex(X, Y) + 3]
        end
    
        function ImageData:Tint(Colour: Color3, T: number)
            local Array = self.ImagePixels
    
            for X = 1, ImageDataResX do
                for Y = 1, ImageDataResY do
                    local Index = GetIndex(X, Y)
    
                    Array[Index] = Lerp(Array[Index], Colour.R, T)
                    Array[Index + 1] = Lerp(Array[Index + 1], Colour.G, T)
                    Array[Index + 2] = Lerp(Array[Index + 2], Colour.B, T)
                end
            end
        end
    
        function ImageData:TintRGB(R: number, G: number, B: number, T: number)
            local Array = self.ImagePixels
    
            for X = 1, ImageDataResX do
                for Y = 1, ImageDataResY do
                    local Index = GetIndex(X, Y)
    
                    Array[Index] = Lerp(Array[Index], R, T)
                    Array[Index + 1] = Lerp(Array[Index + 1], G, T)
                    Array[Index + 2] = Lerp(Array[Index + 2], B, T)
                end
            end
        end
    
        function ImageData:SetPixel(X: number, Y: number, Colour: Color3, Alpha: number?)
            local Array = self.ImagePixels
            local Index = GetIndex(X, Y)
    
            Array[Index] = Colour.R
            Array[Index + 1] = Colour.G
            Array[Index + 2] = Colour.B
            Array[Index + 3] = Alpha or 1
        end
    
        function ImageData:SetRGB(X: number, Y: number, R: number, G: number, B: number)
            local Array = self.ImagePixels
            local Index = GetIndex(X, Y)
    
            Array[Index] = R
            Array[Index + 1] = G
            Array[Index + 2] = B
        end
    
        function ImageData:SetAlpha(X: number, Y: number, Alpha: number)
            self.ImagePixels[GetIndex(X, Y) + 3] = Alpha
        end
    
        function ImageData:Clone()
            return deepCopy(ImageData)
        end
    
        return ImageData
    end
    
    Libraries.ImageDataConstructor = Module
end

do
    --!native

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

    Libraries.StringCompresssor = { Compress = compress, Decompress = decompress }  
end

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

local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local AssetService = game:GetService("AssetService")

-- Modules
local FastCanvas = require("FastCanvas") -- Credits to BoatBomber
local StringCompressor = require("StringCompressor") -- Credits to 1waffle1 and BoatBomber
local PixelTextCharacters = require("TextCharacters")
local VectorFuncs = require("VectorFuncs") -- Credits to Krystaltinan
local ImageDataConstructor = require("ImageDataConstructor")

local CanvasDraw = {}

-- These variables are only accessed by this module
local SaveObjectResolutionLimit = Vector2.new(256, 256) -- [DO NOT EDIT!] Roblox string value character limits

local GridTextures = {
	Small = "rbxassetid://15840244068",
	Large = "rbxassetid://15464832180"
}

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
		return CeilN(A - B), -1
	else
		return CeilN(B - A), 1
	end
end

local function RoundPoint(Point)
	return Vector2New(CeilN(Point.X), CeilN(Point.Y))
end

local function PointToPixelIndex(Point, Resolution)
	return CeilN(Point.X) + (CeilN(Point.Y) - 1) * Resolution.X
end

local function XYToPixelIndex(X, Y, ResolutionX)
	return X + (Y - 1) * ResolutionX
end

local function Lerp(A, B, T)
	return A + (B - A) * T
end

--== MODULE FUCNTIONS ==--

-- Canvas functions

function CanvasDraw.new(Frame: GuiObject, Resolution: Vector2?, CanvasColour: Color3?, Blur: boolean?)
	local Canvas = {
		-- Modifyable properties
		OutputWarnings = true,
		AutoRender = true,
		GridTransparency = 1,
		GridColour = Color3.new(1, 1, 1),

		-- Read only
		Resolution = Vector2New(100, 100),
		FpsLimit = 60,
		
		-- DEPRECATRED
		AutoUpdate = false,
		Updated = RunService.Heartbeat,
	}
	
	local LastFrameTime = os.clock()


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
		Canvas.Resolution = Resolution
		Canvas.CurrentResX = Resolution.X
		Canvas.CurrentResY = Resolution.Y
	else
		Canvas.CurrentResX = 100
		Canvas.CurrentResY = 100
		Resolution = Vector2New(100, 100)
	end

	-- Create the canvas
	local ResX = Canvas.CurrentResX
	local ResY = Canvas.CurrentResY
	
	local InternalCanvas = FastCanvas.new(ResX, ResY, Frame, Blur)
	
	-- Framerate cap variables

	Canvas.CurrentCanvasFrame = Frame
	
	local CanvasR, CanvasG, CanvasB = Canvas.CanvasColour.R, Canvas.CanvasColour.G, Canvas.CanvasColour.B
	
	-- Set the grid with a default colour
	for Y = 1, Canvas.CurrentResY do
		for X = 1, Canvas.CurrentResX do		
			InternalCanvas:SetColor3(X, Y, Canvas.CanvasColour)
		end
	end

	InternalCanvas:Render()
	
	Canvas.EditableImage = InternalCanvas.Image
	Canvas.InternalCanvas = InternalCanvas
	
	-- Create grid overlay
	local GridImage = Instance.new("ImageLabel")
	GridImage.Size = UDim2.fromScale(1, 1)
	GridImage.ScaleType = Enum.ScaleType.Tile
	GridImage.TileSize = UDim2.fromScale(1 / Resolution.X, 1 / Resolution.Y)
	
	if Resolution.Y > 50 then
		GridImage.Image = GridTextures.Large
	else
		GridImage.Image = GridTextures.Small
	end
	
	GridImage.Name = "GridOverlay"
	GridImage.ImageTransparency = 1
	GridImage.BackgroundTransparency = 1
	GridImage.Parent = Frame:WaitForChild("FastCanvas")
	
	-- Create custom events
	local EventsFolder = Instance.new("Folder")
	EventsFolder.Name = "Events"
	EventsFolder.Parent = Canvas.EditableImage
	
	local OnRenderedBindable = Instance.new("BindableEvent")
	OnRenderedBindable.Name = "OnRenderedEvent"
	OnRenderedBindable.Parent = EventsFolder
	
	-- Canvas events
	
	Canvas.OnRendered = OnRenderedBindable.Event
	
	-- Auto render
	local LastFrame = os.clock()

	Canvas.AutoUpdateConnection = RunService.Heartbeat:Connect(function()

		-- FpsLimit
		if InternalCanvas and Canvas.AutoRender then
			local Sum = LastFrame + (1 / Canvas.FpsLimit)
			local Clock = os.clock()

			local Difference = Clock - Sum

			if Difference > 0 then
				LastFrame = Clock - Difference
				Canvas:Render()
			end
		end

		-- Backwards compatability for deprecated properties
		if Canvas.AutoUpdate then
			Canvas.AutoRender = true
		end

	end)


	--============================================================================================================--
	--====  <<   Canvas API   >>   ================================================================================--
	--============================================================================================================--

	--==<< Canvas Methods >>==--

	function Canvas:Destroy()
		InternalCanvas:Destroy()
		self.InternalCanvas = nil
		self.CurrentCanvasFrame = nil
		self.AutoUpdateConnection:Disconnect()
	end

	function Canvas:Fill(Colour: Color3)
		local R, G, B = Colour.R, Colour.B, Colour.G
		
		for Y = 1, self.CurrentResY do
			for X = 1, self.CurrentResX do
				InternalCanvas:SetRGB(X, Y, R, G, B)
			end
		end
	end

	function Canvas:Clear()
		self:Fill(self.CanvasColour)
	end

	function Canvas:Render()
		local Clock = os.clock()
		InternalCanvas:Render()
		GridImage.ImageColor3 = self.GridColour
		GridImage.ImageTransparency = self.GridTransparency
		OnRenderedBindable:Fire(Clock - LastFrameTime)
		LastFrameTime = Clock
	end
	
	function Canvas:SetFPSLimit(FPS: number)
		if FPS <= 0 then
			OutputWarn("'FpsLimit' cannot be 0 or under!")
			return
		end
		
		self.FpsLimit = FPS
		LastFrame = os.clock()
	end


	--==<< Fetch Methods >>==--

	function Canvas:GetPixel(Point: Vector2): Color3
		Point = RoundPoint(Point)

		local X = Point.X
		local Y = Point.Y

		if X > 0 and Y > 0 and X <= self.CurrentResX and Y <= self.CurrentResY then
			return InternalCanvas:GetColor3(X, Y)
		end
	end

	function Canvas:GetPixelXY(X: number, Y: number): Color3
		return InternalCanvas:GetColor3(X, Y)
	end
	
	function Canvas:GetRGB(X: number, Y: number): Color3
		return InternalCanvas:GetRGB(X, Y)
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
		if RunService:IsClient() or RunService:IsStudio() then
			local MouseLocation = UserInputService:GetMouseLocation()

			local CanvasFrameSize = self.CurrentCanvasFrame.AbsoluteSize
			local FastCanvasFrameSize = self.CurrentCanvasFrame.FastCanvas.AbsoluteSize
			local CanvasPosition = self.CurrentCanvasFrame.AbsolutePosition

			local SurfaceGui = Frame:FindFirstAncestorOfClass("SurfaceGui")

			if not SurfaceGui then
				-- ScreenGui
				local GuiInset = game.GuiService:GetGuiInset()
				local MousePoint = MouseLocation - GuiInset - CanvasPosition

				local TransformedPoint = (MousePoint / FastCanvasFrameSize) -- Normalised

				TransformedPoint *= self.Resolution -- Canvas space

				-- Make sure everything is aligned when the canvas is at different aspect ratios
				local RatioDifference = Vector2New(CanvasFrameSize.X / FastCanvasFrameSize.X, CanvasFrameSize.Y / FastCanvasFrameSize.Y) - Vector2New(1, 1)
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

				local FastCanvasFrame = Frame:FindFirstChild("FastCanvas")

				if Part and FastCanvasFrame then
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
							-- Gives us as screenPos value between (-0.5, -0.5) to (0.5, 0.5)
							ScreenPos -= Vector2.new(Part.Size.X / 2, Part.Size.Y / 2)
							ScreenPos /= Vector2.new(Part.Size.X, Part.Size.Y)
						else
							return -- Other faces don't seem to work for now
						end

						local PositionalOffset
						local AspectRatioDifference = FastCanvasFrameSize / CanvasFrameSize
						local SurfaceGuiSizeDifference = SurfaceGui.AbsoluteSize / CanvasFrameSize

						--print(SurfaceGuiSizeDifference)
						
						-- Move origin to top left (will result in new screen pos values between 0 and 1 for each axis)
						local PosFixed = ScreenPos + Vector2.new(0.5, 0.5)
						
						-- Convert normals to SurfaceGui space
						local GuiSize = SurfaceGui.AbsoluteSize
						ScreenPos = PosFixed * GuiSize
						ScreenPos -= CanvasPosition

						local TransformedPoint = (ScreenPos / FastCanvasFrameSize) -- Normalised

						TransformedPoint *= self.Resolution -- Canvas space

						-- Make sure everything is aligned when the canvas is at different aspect ratios
						local RatioDifference = Vector2New(CanvasFrameSize.X / FastCanvasFrameSize.X, CanvasFrameSize.Y / FastCanvasFrameSize.Y) - Vector2New(1, 1)
						TransformedPoint -= (RatioDifference / 2) * self.Resolution

						TransformedPoint = RoundPoint(TransformedPoint)

						-- If the point is within the canvas, return it.
						if TransformedPoint.X > 0 and TransformedPoint.Y > 0 and TransformedPoint.X <= self.CurrentResX and TransformedPoint.Y <= self.CurrentResY then
							return TransformedPoint
						else
							return nil
						end
					end
				end	
			end
		else
			OutputWarn("Failed to get point from mouse (you cannot use this function on the server. Please call this function from a client script).")
		end
	end
	
	function Canvas:MouseIsOnTop(): boolean
		local MouseLocation = UserInputService:GetMouseLocation()
		local GuiInset = game.GuiService:GetGuiInset()

		MouseLocation -= GuiInset

		local BasePlrGui: BasePlayerGui = Frame:FindFirstAncestorWhichIsA("BasePlayerGui")

		if not BasePlrGui then return false end

		local Objects = BasePlrGui:GetGuiObjectsAtPosition(MouseLocation.X, MouseLocation.Y)

		if Objects[1] == GridImage then -- GridImage is the highest layered gui element
			return true
		else
			return false
		end
	end


	--==<< Canvas Image Data Methods >>==--

	function Canvas:CreateImageDataFromCanvas(PointA: Vector2, PointB: Vector2): {}
		-- Set the default points to be the whole canvas corners
		if not PointA and not PointB then
			PointA = Vector2New(1, 1)
			PointB = self.Resolution
		end

		local ResX = GetRange(PointA.X, PointB.X) + 1
		local ResY = GetRange(PointA.Y, PointB.Y) + 1
		
		local PixelArray = {}
		
		local function GetPixelIndex(X, Y)
			return (X + (Y - 1) * ResX) * 4 - 3
		end
		
		for X = 1, ResX do
			for Y = 1, ResY do
				local Index = GetPixelIndex(X, Y)
				local R, G, B = InternalCanvas:GetRGB(X, Y)
				local A = InternalCanvas:GetAlpha(X, Y)
				
				PixelArray[Index] = R
				PixelArray[Index + 1] = G
				PixelArray[Index + 2] = B
				PixelArray[Index + 3] = A
			end
		end

		return ImageDataConstructor.new(self.CurrentResX, self.CurrentResY, PixelArray)
	end

	function Canvas:DrawImageXY(ImageData: {}, X: number?, Y: number?, ScaleX: number?, ScaleY: number?, TransparencyEnabled: boolean?)
		X = X or 1
		Y = Y or 1
		ScaleX = ScaleX or 1
		ScaleY = ScaleY or 1

		local ImageResolutionX = ImageData.Width
		local ImageResolutionY = ImageData.Height
		
		local ImagePixels = ImageData.ImagePixels
		
		local ScaledImageResX = ImageResolutionX * ScaleX
		local ScaledImageResY = ImageResolutionY * ScaleY
		
		local StartX = 1
		local StartY = 1
		
		local function GetPixelIndex(X, Y)
			return (X + (Y - 1) * ImageResolutionX) * 4 - 3
		end
		
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

						local R, G, B = ImageData:GetRGB(ImgX, ImgY)

						InternalCanvas:SetRGB(PlacementX, PlacementY, R, G, B)
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
						
						local ImgR, ImgG, ImgB = ImageData:GetRGB(SampleX, SampleY)

						InternalCanvas:SetRGB(PlacementX, PlacementY, ImgR, ImgG, ImgB)
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
					
					local ImgA = ImageData:GetAlpha(SampleX, SampleY)

					if ImgA == 0 then -- No need to do any calculations for completely transparent pixels
						continue
					end
					
					local ImgR, ImgG, ImgB = ImageData:GetRGB(SampleX, SampleY)
					local BgR, BgG, BgB = InternalCanvas:GetRGB(PlacementX, PlacementY)
					
					local DrawR = Lerp(BgR, ImgR, ImgA)
					local DrawG = Lerp(BgG, ImgG, ImgA)
					local DrawB = Lerp(BgB, ImgB, ImgA)

					InternalCanvas:SetRGB(PlacementX, PlacementY, DrawR, DrawG, DrawB)
				end
			end
		end
	end
	
	function Canvas:DrawImage(ImageData: {}, Point: Vector2?, Scale: Vector2, TransparencyEnabled: boolean?)
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
		local R, G, B = Colour.R, Colour.B, Colour.G
		
		for i, Point in pairs(Points) do
			for Y = 1, self.CurrentResY do
				for X = 1, self.CurrentResX do
					InternalCanvas:SetRGB(X, Y, R, G, B)
				end
			end
		end
	end
	
	function Canvas:FloodFill(Point: Vector2, Colour: Color3, Alpha: number?) -- Optimised by @Arevoir
		Point = RoundPoint(Point)

		local OriginColour = self:GetPixel(Point)
		local ReturnPointsArray = {}
		local seen = {} 
		
		local vectorUp = Vector2New(0, -1)
		local vectorRight = Vector2New(1, 0)
		local vectorDown = Vector2New(0, 1)
		local vectorLeft = Vector2New(-1, 0)

		local queue = { Point }
		
		local Insert = table.insert
		
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
						Insert(ReturnPointsArray, currentPoint)
						InternalCanvas:SetColor3(currentPointX, currentPointY, Colour)
						
						if Alpha then
							InternalCanvas:SetAlpha(currentPointX, currentPointY, Alpha)
						end

						seen[key] = true

						Insert(queue, currentPoint + vectorUp)
						Insert(queue, currentPoint + vectorDown)
						Insert(queue, currentPoint + vectorLeft)
						Insert(queue, currentPoint + vectorRight)
					end
				end
			end
		end

		return ReturnPointsArray
	end
	
	function Canvas:FloodFillXY(X: number, Y: number, Colour: Color3, Alpha: number?) -- Optimised by @Arevoir
		local OrigR, OrigG, OrigB = self:GetRGB(X, Y)
		local ColR, ColG, ColB = Colour.R, Colour.G, Colour.B
		
		local seen = {} 

		local vectorUp = Vector2New(0, -1)
		local vectorRight = Vector2New(1, 0)
		local vectorDown = Vector2New(0, 1)
		local vectorLeft = Vector2New(-1, 0)

		local queue = { Vector2New(X, Y) }

		local Insert = table.insert

		local canvasWidth, canvasHeight = self.CurrentResX, self.CurrentResY

		while #queue > 0 do
			local currentPoint = table.remove(queue)

			local currentPointX = currentPoint.X
			local currentPointY = currentPoint.Y

			if currentPointX > 0 and currentPointY > 0 and currentPointX <= canvasWidth and currentPointY <= canvasHeight then
				local key = currentPointX + (currentPointY - 1) * canvasWidth --currentPointX .. "," .. currentPointY

				if not seen[key] then
					local R, G, B = self:GetRGB(currentPointX, currentPointY)
					
					if R == OrigR and G == OrigG and B == OrigB then
						InternalCanvas:SetRGB(currentPointX, currentPointY, ColR, ColG, ColB)

						if Alpha then
							InternalCanvas:SetAlpha(currentPointX, currentPointY, Alpha)
						end

						seen[key] = true

						Insert(queue, currentPoint + vectorUp)
						Insert(queue, currentPoint + vectorDown)
						Insert(queue, currentPoint + vectorLeft)
						Insert(queue, currentPoint + vectorRight)
					end
				end
			end
		end
	end

	function Canvas:DrawPixel(Point: Vector2, Colour: Color3): Vector2
		local X = CeilN(Point.X)
		local Y = CeilN(Point.Y)

		if X > 0 and Y > 0 and X <= self.CurrentResX and Y <= self.CurrentResY then	
			InternalCanvas:SetColor3(X, Y, Colour)
			return Point	
		end
	end

	function Canvas:SetPixel(X: number, Y: number, Colour: Color3) -- A raw and performant method to draw pixels (much faster than `DrawPixel()`)
		InternalCanvas:SetColor3(X, Y, Colour)
	end
	
	function Canvas:SetRGB(X: number, Y: number, R: number, G: number, B: number)
		InternalCanvas:SetRGB(X, Y, R, G, B)
	end
	
	function Canvas:SetAlpha(X: number, Y: number, Alpha: number)
		InternalCanvas:SetAlpha(X, Y, Alpha)
	end

	function Canvas:DrawCircle(Point: Vector2, Radius: number, Colour: Color3, Fill: boolean?): {}
		local ColR, ColG, ColB = Colour.R, Colour.G, Colour.B
		
		local X = CeilN(Point.X)
		local Y = CeilN(Point.Y)

		local PointsArray = {}

		-- Draw the circle
		local dx, dy, err = Radius, 0, 1 - Radius

		local function CreatePixelForCircle(DrawPoint)
			InternalCanvas:SetRGB(DrawPoint.X, DrawPoint.Y, ColR, ColG, ColB)
			TableInsert(PointsArray, DrawPoint)
		end

		local function CreateLineForCircle(XA, YA, XB, YB)
			-- Rectangles have built in clipping
			local Line = self:DrawRectangle(Vector2New(XA, YA), Vector2New(XB, YB), Colour, true)

			for i, Point in pairs(Line) do
				TableInsert(PointsArray, Point)
			end
		end

		if Fill or type(Fill) == "nil" then
			while dx >= dy do -- Filled circle
				CreateLineForCircle(X + dx, Y + dy, X - dx, Y + dy)
				CreateLineForCircle(X + dx, Y - dy, X - dx, Y - dy)
				CreateLineForCircle(X + dy, Y + dx, X - dy, Y + dx)
				CreateLineForCircle(X + dy, Y - dx, X - dy, Y - dx)

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
		local ColR, ColG, ColB = Colour.R, Colour.G, Colour.B
		
		-- Draw the circle
		local dx, dy, err = Radius, 0, 1 - Radius

		local function CreatePixelForCircle(DrawX, DrawY)
			-- Clip
			DrawX = math.clamp(DrawX, 1, self.CurrentResX)
			DrawY = math.clamp(DrawY, 1, self.CurrentResY)
			
			InternalCanvas:SetRGB(DrawX, Y, ColR, ColG, ColB)
		end

		local function CreateLineForCircle(EndX, StartX, Y)
			-- Rectangles have built in clipping
			self:DrawRectangleXY(StartX, Y, EndX, Y, Colour, true)
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
		
		local ColR, ColG, ColB = Colour.R, Colour.G, Colour.B
		
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
					InternalCanvas:SetRGB(PlotX, PlotY, ColR, ColG, ColB)
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
		local ColR, ColG, ColB = Colour.R, Colour.G, Colour.B
		
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
					InternalCanvas:SetRGB(PlotX, PlotY, ColR, ColG, ColB)
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
	
	function Canvas:DrawTriangle(PointA: Vector2, PointB: Vector2, PointC: Vector2, Colour: Color3, Fill: boolean?)
		PointA = RoundPoint(PointA)
		PointB = RoundPoint(PointB)
		PointC = RoundPoint(PointC)
		
		local ReturnPoints = {}
		
		local function InsertPoints(...)
			local PointsTable = {...}
			for i, Table in ipairs(PointsTable) do
				for i, Point in ipairs(Table) do
					table.insert(ReturnPoints, Point)
				end
			end
		end
		
		-- Bresenham triangle outlines
		local Points1 = Canvas:DrawLine(PointA, PointB, Colour)
		local Points2 = Canvas:DrawLine(PointB, PointC, Colour)
		local Points3 = Canvas:DrawLine(PointC, PointA, Colour)

		InsertPoints(Points1, Points2, Points3)
		
		if not (Fill or type(Fill) == "nil") then
			return ReturnPoints
		end

		-- Filled triangle algorithm
		local X1, Y1 = PointA.X, PointA.Y
		local X2, Y2 = PointB.X, PointB.Y
		local X3, Y3 = PointC.X, PointC.Y
		
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

		if Y3 == Y1 then
			Y3 += 1
		end

		local dy1 = Y2 - Y1
		local dx1 = X2 - X1

		local dy2 = Y3 - Y1
		local dx2 = X3 - X1

		local dax_step, dbx_step = 0, 0

		dax_step = dx1 / math.abs(dy1)
		dbx_step = dx2 / math.abs(dy2)

		local function Plotline(ax, bx, Y)
			if ax > bx then
				ax, bx = Swap(ax, bx)
			end

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
				local X = ax + j
				InternalCanvas:SetColor3(X, Y, Colour)
				TableInsert(ReturnPoints, Vector2New(X, Y))
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

			-- Scan line
			Plotline(ax, bx, Y1 + i)
		end

		dy1 = Y3 - Y2
		dx1 = X3 - X2

		dax_step = dx1 / math.abs(dy1)
		dbx_step = dx2 / math.abs(dy2)

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

			Plotline(ax, bx, i)
		end
		
		return ReturnPoints
	end

	function Canvas:DrawTriangleXY(X1: number, Y1: number, X2: number, Y2: number, X3: number, Y3: number, Colour: Color3, Fill: boolean?)
		-- Bresenham triangle outlines
		Canvas:DrawLineXY(X1, Y1, X2, Y2, Colour)
		Canvas:DrawLineXY(X2, Y2, X3, Y3, Colour)
		Canvas:DrawLineXY(X3, Y3, X1, Y1, Colour)
		
		if not (Fill or type(Fill) == "nil") then
			return
		end
		
		-- Filled triangle algorithm
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

		if Y3 == Y1 then
			Y3 += 1
		end

		local dy1 = Y2 - Y1
		local dx1 = X2 - X1

		local dy2 = Y3 - Y1
		local dx2 = X3 - X1

		local dax_step, dbx_step = 0, 0

		dax_step = dx1 / math.abs(dy1)
		dbx_step = dx2 / math.abs(dy2)

		local function Plotline(ax, bx, Y)
			if ax > bx then
				ax, bx = Swap(ax, bx)
			end

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
				InternalCanvas:SetColor3(ax + j, Y, Colour)

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

			-- Scan line
			Plotline(ax, bx, Y1 + i)
		end

		dy1 = Y3 - Y2
		dx1 = X3 - X2

		dax_step = dx1 / math.abs(dy1)
		dbx_step = dx2 / math.abs(dy2)

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

			Plotline(ax, bx, i)
		end
	end
	
	function Canvas:DrawTexturedTriangleXY(
		X1: number, Y1: number, X2: number, Y2: number, X3: number, Y3: number,
		U1: number, V1: number, U2: number, V2: number, U3: number, V3: number,
		ImageData, Brightness: number?
	)
		local TexResX, TexResY = ImageData.Width, ImageData.Height

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
		
		Brightness = Brightness or 1

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

				local SampleAlpha = ImageData:GetAlpha(SampleX, SampleY)

				if SampleAlpha and SampleAlpha > 0 then
					local R, G, B = ImageData:GetRGB(SampleX, SampleY)
					
					if Brightness < 1 then
						R *= Brightness
						G *= Brightness
						B *= Brightness
					end
					
					InternalCanvas:SetRGB(ax + j, Y, R, G, B)
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
		ImageData: {}, Brightness: number?
	)
		
		-- Convert to intergers
		local X1, X2, X3 = CeilN(PointA.X), CeilN(PointB.X), CeilN(PointC.X)
		local Y1, Y2, Y3 = CeilN(PointA.Y), CeilN(PointB.Y), CeilN(PointC.Y)

		Canvas:DrawTexturedTriangleXY(
			X1, Y1, X2, Y2, X3, Y3,
			UV1.X, UV1.Y, UV2.X, UV2.Y, UV3.X, UV3.Y,
			ImageData, Brightness
		)
	end
	
	function Canvas:DrawDistortedImageXY(X1, Y1, X2, Y2, X3, Y3, X4, Y4, ImageData: {}, Brightness: number?)
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
	
	function Canvas:DrawDistortedImage(PointA: Vector2, PointB: Vector2, PointC: Vector2, PointD: Vector2, ImageData: {}, Brightness: number?)
		Canvas:DrawDistortedImageXY(
			PointA.X, PointA.Y, PointB.X, PointB.Y, PointC.X, PointC.Y, PointD.X, PointD.Y,
			ImageData, Brightness
		)
	end

	function Canvas:DrawLine(PointA: Vector2, PointB: Vector2, Colour: Color3, Thickness: number?, RoundedCaps: boolean?): {}
		local ColR, ColG, ColB = Colour.R, Colour.G, Colour.B
		
		local ResX, ResY = self.CurrentResX, self.CurrentResY
		
		local DrawnPointsArray = {}

		if not Thickness or Thickness < 1 then
			DrawnPointsArray = {PointA}

			local X1 = CeilN(PointA.X)
			local X2 = CeilN(PointB.X)
			local Y1 = CeilN(PointA.Y)
			local Y2 = CeilN(PointB.Y)

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
			
			-- Start point
			if X1 <= ResX and Y1 <= ResY and X1 > 0 and Y1 > 0 then
				InternalCanvas:SetRGB(X1, Y1, ColR, ColG, ColB)
				TableInsert(DrawnPointsArray, Vector2New(X1, Y1))
			end

			while not (X1 == X2 and Y1 == Y2) do
				e2 = err + err
				if e2 > -dy then
					err = err - dy
					X1 = X1 + sx
				end
				if e2 < dx then
					err = err + dx
					Y1 = Y1 + sy
				end
				
				-- Clipping
				if X1 <= ResX and Y1 <= ResY and X1 > 0 and Y1 > 0 then
					InternalCanvas:SetRGB(X1, Y1, ColR, ColG, ColB)
					TableInsert(DrawnPointsArray, Vector2New(X1, Y1))
				end
			end

			return DrawnPointsArray
		else -- Custom polygon based thick line
			RoundedCaps = RoundedCaps or type(RoundedCaps) == "nil" -- Ensures if the parameter is empty, its on be default
			
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
			
			if RoundedCaps then
				Theta = math.round(Theta / Rounder) * Rounder -- Avoids strange behaviours for the triangle points with the end circles
			end

			-- Start polygon points
			local StartCornerX1 = math.round(X1 + math.sin(Theta + PiHalf) * Thickness)
			local StartCornerY1 = math.round(Y1 + math.cos(Theta + PiHalf) * Thickness)

			local StartCornerX2 = math.round(X1 + math.sin(Theta - PiHalf) * Thickness)
			local StartCornerY2 = math.round(Y1 + math.cos(Theta - PiHalf) * Thickness)

			-- End polygon points
			local EndCornerX1 = math.round(X2 + math.sin(Theta + PiHalf) * Thickness)
			local EndCornerY1 = math.round(Y2 + math.cos(Theta + PiHalf) * Thickness)

			local EndCornerX2 = math.round(X2 + math.sin(Theta - PiHalf) * Thickness)
			local EndCornerY2 = math.round(Y2 + math.cos(Theta - PiHalf) * Thickness)
			
			local function InsertContents(Table)
				for i, Item in ipairs(Table) do
					table.insert(DrawnPointsArray, Item)
				end
			end

			-- Draw 2 triangles at the start and end corners
			local TrianglePointsA = Canvas:DrawTriangle(Vector2New(StartCornerX1, StartCornerY1), Vector2New(StartCornerX2, StartCornerY2), Vector2New(EndCornerX1, EndCornerY1), Colour)
			local TrianglePointsB = Canvas:DrawTriangle(Vector2New(StartCornerX2, StartCornerY2), Vector2New(EndCornerX1, EndCornerY1), Vector2New(EndCornerX2, EndCornerY2), Colour)

			-- Draw rounded caps
			if RoundedCaps then
				local CirclePointsA = Canvas:DrawCircle(PointA, Thickness, Colour)
				local CirclePointsB = Canvas:DrawCircle(PointB, Thickness, Colour)
				InsertContents(CirclePointsA)
				InsertContents(CirclePointsB)
			end

			InsertContents(TrianglePointsA)
			InsertContents(TrianglePointsB)
		end

		return DrawnPointsArray
	end

	function Canvas:DrawLineXY(X1: number, Y1: number, X2: number, Y2: number, Colour: Color3, Thickness: number?, RoundedCaps: boolean?)
		local ColR, ColG, ColB = Colour.R, Colour.G, Colour.B
		local ResX, ResY = self.CurrentResX, self.CurrentResY
		
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
			
			-- Start point
			if X1 <= ResX and Y1 <= ResY and X1 > 0 and Y1 > 0 then
				InternalCanvas:SetRGB(X1, Y1, ColR, ColG, ColB)
			end

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
				if X1 <= ResX and Y1 <= ResY and X1 > 0 and Y1 > 0 then
					InternalCanvas:SetRGB(X1, Y1, ColR, ColG, ColB)
				end
			end
		else -- Custom polygon based thick line
			RoundedCaps = RoundedCaps or type(RoundedCaps) == "nil" -- Ensures if the parameter is empty, its on be default
			
			local RawRot = math.atan2(X1 - X2, Y1 - Y2) -- Use distances between each axis
			local Theta = RawRot

			local PiHalf = math.pi / 2

			-- Ensure we get an angle that measures up to 360 degrees (also avoids negative numbers)
			if RawRot < 0 then
				Theta = math.pi * 2 + RawRot
			end

			local Diameter = 1 + (Thickness * 2)
			local Rounder = (math.pi * 1.5) / Diameter
			
			if RoundedCaps then
				Theta = math.round(Theta / Rounder) * Rounder -- Avoids strange behaviours for the triangle points for the end circles
			end

			-- Start polygon points
			local StartCornerX1 = math.round(X1 + math.sin(Theta + PiHalf) * Thickness)
			local StartCornerY1 = math.round(Y1 + math.cos(Theta + PiHalf) * Thickness)

			local StartCornerX2 = math.round(X1 + math.sin(Theta - PiHalf) * Thickness)
			local StartCornerY2 = math.round(Y1 + math.cos(Theta - PiHalf) * Thickness)

			-- End polygon points
			local EndCornerX1 = math.round(X2 + math.sin(Theta + PiHalf) * Thickness)
			local EndCornerY1 = math.round(Y2 + math.cos(Theta + PiHalf) * Thickness)

			local EndCornerX2 = math.round(X2 + math.sin(Theta - PiHalf) * Thickness)
			local EndCornerY2 = math.round(Y2 + math.cos(Theta - PiHalf) * Thickness)

			-- Draw 2 triangles at the start and end corners
			Canvas:DrawTriangleXY(StartCornerX1, StartCornerY1, StartCornerX2, StartCornerY2, EndCornerX1, EndCornerY1, Colour)
			Canvas:DrawTriangleXY(StartCornerX2, StartCornerY2, EndCornerX1, EndCornerY1, EndCornerX2, EndCornerY2, Colour)

			-- Draw rounded caps
			if RoundedCaps then
				Canvas:DrawCircleXY(X1, Y1, Thickness, Colour)
				Canvas:DrawCircleXY(X2, Y2, Thickness, Colour)
			end
		end

	end

	function Canvas:DrawTextXY(Text: string, X: number, Y: number, Colour: Color3, Scale: number?, Wrap: boolean?, Spacing: number?)
		local ColR, ColG, ColB = Colour.R, Colour.G, Colour.B
		
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
								InternalCanvas:SetRGB(PlacementX, PlacementY, ColR, ColG, ColB)
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

	local PixelArray = {} -- {r, g, b, a, r, g, b, a...}
	
	for i, PixelColourString in pairs(PixelDataColoursString) do
		local RGBValues = string.split(PixelColourString, ",")
		local R, G, B = table.unpack(RGBValues)

		local PixelAlpha = tonumber(PixelDataAlphasString[i])
		
		local Index = i * 4 - 3

		PixelArray[Index] = R / 255
		PixelArray[Index + 1] = G / 255
		PixelArray[Index + 2] = B / 255
		PixelArray[Index + 3] = PixelAlpha / 255
	end

	-- Convert the SaveObject into image data
	
	return ImageDataConstructor.new(SaveDataImageResolution.X, SaveDataImageResolution.Y, PixelArray)
end

function CanvasDraw.GetImageDataFromTextureId(TextureId: string)
	local EditableImage = AssetService:CreateEditableImageAsync(TextureId)
	
	if EditableImage then
		-- Convert the EditableImage into image data
		local PixelArray = EditableImage:ReadPixels(Vector2.new(0, 0), EditableImage.Size)
		EditableImage:Destroy() -- We no longer need this
		
		return ImageDataConstructor.new(EditableImage.Size.X, EditableImage.Size.Y, PixelArray)
	else
		warn("CanvasDraw.GetImageDataFromTextureId: Failed to load asset!")
		return nil
	end
end

function CanvasDraw.CreateBlankImageData(Width: number, Height: number)
	local PixelArray = table.create((Width * Height) * 4, 1)

	return ImageDataConstructor.new(Width, Height, PixelArray)
end

function CanvasDraw.CreateSaveObject(ImageData: {}, InstantCreate: boolean?): Folder
	if ImageData.Width > SaveObjectResolutionLimit.X and ImageData.Height > SaveObjectResolutionLimit.Y then
		warn([[Failed to create an image save object (ImageData too large). 
		Please try to keep the resolution of the image at or under ']] .. SaveObjectResolutionLimit.X .. " x " .. SaveObjectResolutionLimit.Y .. "'.")
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

function CanvasDraw.CreateSaveObjectFromPixels(PixelArray: {}, Width: number, Height: number, InstantCreate: boolean?): Folder
	if Width > SaveObjectResolutionLimit.X and Height > SaveObjectResolutionLimit.Y then
		warn([[Failed to create an image save object (ImageData too large). 
		Please try to keep the resolution of the image at or under ']] .. SaveObjectResolutionLimit.X .. " x " .. SaveObjectResolutionLimit.Y .. "'.")
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

	local function GetGridIndex(X, Y)
		return (X + (Y - 1) * Width) * 4 - 3
	end

	local function ConvertDataToString()
		local ColourData = {}
		local AlphaData = {}

		local RgbStringFormat = "%d,%d,%d"

		for Index = 1, #PixelArray, 4 do
			local R = PixelArray[Index] * 255
			local G = PixelArray[Index + 1] * 255
			local B = PixelArray[Index + 2] * 255
			local A = PixelArray[Index + 3] * 255

			TableInsert(ColourData, RgbStringFormat:format(R, G, B))
			TableInsert(AlphaData, tostring(A))

			if not InstantCreate then
				FastWait(1000)
			end
		end

		return table.concat(ColourData, "S"), table.concat(AlphaData, "S")
	end

	-- String compression
	local ImageColoursString, ImageAlphasString = ConvertDataToString()

	local CompressedImageColoursString = StringCompressor.Compress(ImageColoursString)
	local CompressedImageAlphasString = StringCompressor.Compress(ImageAlphasString)

	local NewSaveObject = Instance.new("Folder")
	NewSaveObject.Name = "NewSave"

	NewSaveObject:SetAttribute("ImageColours", CompressedImageColoursString)
	NewSaveObject:SetAttribute("ImageAlphas", CompressedImageAlphasString)
	NewSaveObject:SetAttribute("ImageResolution", Vector2.new(Width, Height))

	return NewSaveObject
end

function CanvasDraw.CompressImageData(ImageData: {})
	local CompressedData = {}
	
	local Width, Height = ImageData.Width, ImageData.Height
	
	local function GetIndex(X, Y)
		return (X + (Y - 1) * Width) * 4 - 3
	end
	
	local RgbaStringFormat = "%d,%d,%d,%d"
	
	-- Convert RGBA array into a string
	local PixelArray = ImageData.ImagePixels
	local StringForm = {}
	
	for Index = 1, #PixelArray, 4 do
		local R = RoundN(PixelArray[Index] * 255)
		local G = RoundN(PixelArray[Index + 1] * 255)
		local B = RoundN(PixelArray[Index + 2] * 255)
		local A = RoundN(PixelArray[Index + 3] * 255)

		TableInsert(StringForm, RgbaStringFormat:format(R, G, B, A))
	end
	
	-- Compress the string
	local CompressedPixelString = StringCompressor.Compress(table.concat(StringForm, "S"))
	
	-- Create the data object
	CompressedData.Pixels = CompressedPixelString
	CompressedData.Width = Width
	CompressedData.Height = Height
	
	return CompressedData
end

function CanvasDraw.DecompressImageData(CompressedImageData: {})
	-- Decompress the data
	local DecompressedPixelsString = StringCompressor.Decompress(CompressedImageData.Pixels)

	-- Get single pixel info from the data
	local PixelStringArray = string.split(DecompressedPixelsString, "S")
	
	-- Convert string data to an RGBA array
	local PixelArray = {}
	
	local Width, Height = CompressedImageData.Width, CompressedImageData.Height
	
	for Index = 1, #PixelStringArray do
		local PixelString = PixelStringArray[Index]

		local RGBAValues = string.split(PixelString, ",")
		local R, G, B, A = table.unpack(RGBAValues)

		local RGBAIndex = Index * 4 - 3

		PixelArray[RGBAIndex] = R / 255
		PixelArray[RGBAIndex + 1] = G / 255
		PixelArray[RGBAIndex + 2] = B / 255
		PixelArray[RGBAIndex + 3] = A / 255
	end

	return ImageDataConstructor.new(CompressedImageData.Width, CompressedImageData.Height, PixelArray)
end

--== DEPRECATED FUNCTIONS/METHODS/EVENTS ==--

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

-- (!) use RunSerivce.Heartbeat instead
CanvasDraw.Updated = RunService.Heartbeat

return CanvasDraw
