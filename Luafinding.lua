-- // https://github.com/GlorifiedPig/Luafinding

local Heap = {}
Heap.__index = Heap

local function findLowest( a, b )
    return a < b
end

local function newHeap( template, compare )
    return setmetatable( {
        Data = {},
        Compare = compare or findLowest,
        Size = 0
    }, template )
end

local function sortUp( heap, index )
    if index <= 1 then return end
    local pIndex = index % 2 == 0 and index / 2 or ( index - 1 ) / 2

    if not heap.Compare( heap.Data[pIndex], heap.Data[index] ) then
        heap.Data[pIndex], heap.Data[index] = heap.Data[index], heap.Data[pIndex]
        sortUp( heap, pIndex )
    end
end

local function sortDown( heap, index )
    local leftIndex, rightIndex, minIndex
    leftIndex = index * 2
    rightIndex = leftIndex + 1
    if rightIndex > heap.Size then
        if leftIndex > heap.Size then return
        else minIndex = leftIndex end
    else
        if heap.Compare( heap.Data[leftIndex], heap.Data[rightIndex] ) then minIndex = leftIndex
        else minIndex = rightIndex end
    end

    if not heap.Compare( heap.Data[index], heap.Data[minIndex] ) then
        heap.Data[index], heap.Data[minIndex] = heap.Data[minIndex], heap.Data[index]
        sortDown( heap, minIndex )
    end
end

function Heap:Empty()
    return self.Size == 0
end

function Heap:Clear()
    self.Data, self.Size, self.Compare = {}, 0, self.Compare or findLowest
    return self
end

function Heap:Push( item )
    if item then
        self.Size = self.Size + 1
        self.Data[self.Size] = item
        sortUp( self, self.Size )
    end
    return self
end

function Heap:Pop()
    local root
    if self.Size > 0 then
        root = self.Data[1]
        self.Data[1] = self.Data[self.Size]
        self.Data[self.Size] = nil
        self.Size = self.Size - 1
        if self.Size > 1 then
            sortDown( self, 1 )
        end
    end
    return root
end

local Heap = setmetatable( Heap, { __call = function( self, ... ) return newHeap( self, ... ) end } )

local Vector = Vector2.new

local Luafinding = {}
Luafinding.__index = Luafinding

-- This instantiates a new Luafinding class for usage later.
-- "start" and "finish" should both be 2 dimensional vectors, or just a table with "x" and "y" keys. See the note at the top of this file.
-- positionOpenCheck can be a function or a table.
-- If it's a function it must have a return value of true or false depending on whether or not the position is open.
-- If it's a table it should simply be a table of values such as "pos[x][y] = true".

function Luafinding:Initialize( start, finish, positionOpenCheck )
    local newPath = setmetatable( { Start = start, Finish = finish, PositionOpenCheck = positionOpenCheck }, Luafinding )
    newPath:CalculatePath()
    return newPath
end

local function distance( start, finish )
    local dx = start.x - finish.x
    local dy = start.y - finish.y
    return dx * dx + dy * dy
end

local positionIsOpen
local function positionIsOpenTable( pos, check ) return check[pos.x] and check[pos.x][pos.y] end
local function positionIsOpenCustom( pos, check ) return check( pos ) end

local adjacentPositions = {
    Vector( 0, -1 ),
    Vector( -1, 0 ),
    Vector( 0, 1 ),
    Vector( 1, 0 ),
    Vector( -1, -1 ),
    Vector( 1, -1 ),
    Vector( -1, 1 ),
    Vector( 1, 1 )
}

local function fetchOpenAdjacentNodes( pos, positionOpenCheck )
    local result = {}

    for i = 1, #adjacentPositions do
        local adjacentPos = pos + adjacentPositions[i]
        if positionIsOpen( adjacentPos, positionOpenCheck ) then
            table.insert( result, adjacentPos )
        end
    end

    return result
end

-- This is the function used to actually calculate the path.
-- It returns the calcated path table, or nil if it cannot find a path.
function Luafinding:CalculatePath()
    local start, finish, positionOpenCheck = self.Start, self.Finish, self.PositionOpenCheck
    if not positionOpenCheck then return end
    positionIsOpen = type( positionOpenCheck ) == "table" and positionIsOpenTable or positionIsOpenCustom
    if not positionIsOpen( finish, positionOpenCheck ) then return end
    local open, closed = Heap(), {}

    start.gScore = 0
    start.hScore = distance( start, finish )
    start.fScore = start.hScore

    open.Compare = function( a, b )
        return a.fScore < b.fScore
    end

    open:Push( start )

    while not open:Empty() do
        local current = open:Pop()
        local currentId = current:ID()
        if not closed[currentId] then
            if current == finish then
                local path = {}
                while true do
                    if current.previous then
                        table.insert( path, 1, current )
                        current = current.previous
                    else
                        table.insert( path, 1, start )
                        self.Path = path
                        return path
                    end
                end
            end

            closed[currentId] = true

            local adjacents = fetchOpenAdjacentNodes( current, positionOpenCheck )
            for i = 1, #adjacents do
                local adjacent = adjacents[i]
                if not closed[adjacent:ID()] then
                    local added_gScore = current.gScore + distance( current, adjacent )

                    if not adjacent.gScore or added_gScore < adjacent.gScore then
                        adjacent.gScore = added_gScore
                        if not adjacent.hScore then
                            adjacent.hScore = distance( adjacent, finish )
                        end
                        adjacent.fScore = added_gScore + adjacent.hScore

                        open:Push( adjacent )
                        adjacent.previous = current
                    end
                end
            end
        end
    end
end

function Luafinding:GetPath()
    return self.Path
end

function Luafinding:GetDistance()
    local path = self.Path
    if not path then return end
    return distance( path[1], path[#path] )
end

function Luafinding:GetTiles()
    local path = self.Path
    if not path then return end
    return #path
end

function Luafinding:__tostring()
    local path = self.Path
    local string = ""

    if path then
        for k, v in ipairs( path ) do
            local formatted = ( k .. ": " .. v )
            string = k == 1 and formatted or string .. "\n" .. formatted
        end
    end

    return string
end

return setmetatable( Luafinding, { __call = function( self, ... ) return self:Initialize( ... ) end } )
