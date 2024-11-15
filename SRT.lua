-- // https://gist.github.com/boatbomber/e15fc9456ddd4471aa98099269c7acdb

--[=[
	SRT.lua
	boatbomber
	6/6/2021

	A parser for SRT files, cuz BitwiseAndrea inspired me

	function SRT.Parse(fileSource: string)
	returns an array of captions like so:
	{
		[1] =  ▼ table = {
			["Index"] = 1,
			["EndTime"] = 6.177,
			["EndTimeMilli"] = 6177,
			["StartTime"] = 3.4,
			["StartTimeMilli"] = 3400,
			["Text"] = "In this lesson, we're going to
		be talking about finance. And"
		},
		[2] =  ▼ table = {
			["Index"] = 2,
			["EndTime"] = 10.009,
			["EndTimeMilli"] = 10009,
			["StartTime"] = 6.177,
			["StartTimeMilli"] = 6177,
			["Text"] = "one of the most important aspects
		of finance is interest."
		},
	}
]=]

local SRT = {};

function SRT.Parse(fileSource: string)
	local Chunks = string.split(fileSource, "\n\n")
	local Captions = table.create(#Chunks)

	for i, Chunk in ipairs(Chunks) do
		local Cap = {
			Index = i;
			Text = nil;
			StartTimeMilli = 0;
			EndTimeMilli = 0;
			StartTime = 0;
			EndTime = 0;
		}

		-- hours:minutes:seconds,milliseconds
		local StartHour,StartMinute,StartSecond,StartMilli, EndHour,EndMinute,EndSecond,EndMilli = string.match(Chunk, "([%d]-):([%d]-):([%d]-),([%d]-) %-%-> ([%d]-):([%d]-):([%d]-),([%d]+)")
		
		Cap.StartTimeMilli = (tonumber(StartHour) * 3600000) + (tonumber(StartMinute) * 60000) + (tonumber(StartSecond) * 1000) + tonumber(StartMilli)
		Cap.EndTimeMilli = (tonumber(EndHour) * 3600000) + (tonumber(EndMinute) * 60000) + (tonumber(EndSecond) * 1000) + tonumber(EndMilli)

		Cap.StartTime = Cap.StartTimeMilli/1000
		Cap.EndTime = Cap.EndTimeMilli/1000

		Cap.Text = string.gsub(Chunk, "^.-\n.-\n", "")

		table.insert(Captions,Cap)
	end

	return Captions
end

return SRT
