local AnimationTrack
local twait = task.wait
local http = game:GetService("HttpService")
local tween = game:GetService("TweenService")

do

	AnimationTrack = {}
	AnimationTrack.Rigs = {}
	AnimationTrack.Speed = 1
	AnimationTrack.Stall = 0
	AnimationTrack.Length = 0
	AnimationTrack.Weight = 1
	AnimationTrack.Looped = false
	AnimationTrack.RealWeight = 1
	AnimationTrack.lerpFactor = .6
	AnimationTrack.TimePosition = 0
	AnimationTrack.IsPlaying = false
	AnimationTrack.__index = AnimationTrack
	AnimationTrack.NoDisableTransition = true

	local function enumExists(type, value)
		return pcall(function()
			return Enum[type][value] ~= nil
		end)
	end

	function AnimationTrack.Destroy(self)
		if not self then
			return
		end

		if self.Connections then
			for _, v in pairs(self.Connections) do
				v:Disconnect()
			end

			table.clear(self.Connections)
		end

		if self.Binds then
			for _, v in pairs(self.Binds) do
				v:Destroy()
			end

			table.clear(self.Binds)
		end

		table.clear(self.Cache)
		table.clear(self.Used)
		self.StopBind:Destroy()
		self.StopBind = nil

		local stuff = AnimationTrack.Rigs[self.Rig]

		if stuff then
			for i, v in pairs(stuff.Animations) do
				if v == self then
					stuff.Animations[i] = nil
					break
				end
			end
		end

		table.clear(self)
		self = nil
	end

	function AnimationTrack.new()
		local be = Instance.new("BindableEvent", script)

		local track = setmetatable({}, AnimationTrack)
		track.Rigs = nil

		track.Used = {}
		track.Cache = {}
		track.Binds = {}
		track.StopBind = be
		track.Connections = {}
		track.Stopped = be.Event
		track.KeyframeMarkers = {}
		track.Identifier = http:GenerateGUID()

		return track
	end

	function AnimationTrack.GetMarkerReachedSignal(self, marker)
		if not self.Binds[marker] then
			local be = Instance.new("BindableEvent")
			self.Binds[marker] = be
		end

		return self.Binds[marker].Event
	end

	function AnimationTrack.GetKeyframeReachedSignal(self, keyframe)
		if typeof(keyframe) == "number" then
			local num = keyframe
			keyframe = self.Animation[num]
			assert(keyframe, `Keyframe #{num} does not exist!`)
		end

		assert(table.find(self.Animation, keyframe), "Keyframe does not exist!")

		if not self.Binds[keyframe] then
			local be = Instance.new("BindableEvent")
			self.Binds[keyframe] = be
		end

		return self.Binds[keyframe].Event
	end

	function AnimationTrack.AdjustWeight(self, weight)
		self.RealWeight = weight
		self.Weight = self.RealWeight
	end

	function AnimationTrack.setRig(self, rig)
		assert(self.Animation, "Must set Animation before setting Rig!")

		self.Rig = rig

		-- // funny variable name
		local boner = rig:FindFirstChild("InitialPoses")

		if boner then
			local root = rig:FindFirstChildWhichIsA("Bone", true):FindFirstAncestorWhichIsA("BasePart")

			if not root then
				boner = nil
				return
			end

			for _, v in pairs(boner:GetChildren()) do
				if string.find(v.Name, "_Initial") then
					local bone = root:FindFirstChild(string.gsub(v.Name, "_Initial", ""), true)

					if not bone then
						continue
					end

					bone:SetAttribute("Initial", v.Value)
				end
			end
		end

		if not AnimationTrack.Rigs[rig] then
			AnimationTrack.Rigs[rig] = {
				Poses = {},
				Welds = {},
				Animations = {self}
			}

			local cnt

			cnt = game:GetService("RunService").PreAnimation:Connect(function()
				if not AnimationTrack.Rigs[rig] then
					cnt:Disconnect()
				end

				local allDone = true

				for _, v in pairs(AnimationTrack.Rigs[rig].Animations) do
					if v.IsPlaying then
						allDone = false
						break
					end
				end

				if not boner then
					for i, v in pairs(AnimationTrack.Rigs[rig].Welds) do
						if not v.Parent then
							AnimationTrack.Rigs[rig].Welds[i] = nil
							continue
						end

						if not allDone then
							v.Enabled = v:GetAttribute("Enabled") or true
							v.C0 = v.Parent.C0 * AnimationTrack.Rigs[rig].Poses[i]
						else
							if not self.NoDisableTransition then
								v.C0 = v.C0:Lerp(v.Parent.C0 * v.Parent.Transform, self.lerpFactor)

								if (v.C0.Position - (v.Parent.C0 * v.Parent.Transform).Position).Magnitude <= .1 then
									if not v.Enabled then
										v.Enabled = false
									end

									if AnimationTrack.Rigs[self.Rig] then
										AnimationTrack.Rigs[self.Rig].Poses[i] = CFrame.new()
									end
								end
							else
								v.Enabled = false

								if AnimationTrack.Rigs[self.Rig] then
									AnimationTrack.Rigs[self.Rig].Poses[i] = v.Parent.Transform
								end
							end
						end
					end
				else
					for i, v in pairs(AnimationTrack.Rigs[rig].Welds) do
						if not v:GetAttribute("Initial") then
							AnimationTrack.Rigs[rig].Welds[i] = nil
							continue
						end

						if not allDone then
							v.CFrame = v:GetAttribute("Initial") * AnimationTrack.Rigs[rig].Poses[i]
						else
							v.CFrame = v:GetAttribute("Initial")

							if AnimationTrack.Rigs[self.Rig] then
								AnimationTrack.Rigs[self.Rig].Poses[i] = CFrame.new()
							end
						end
					end
				end
			end)

			AnimationTrack.Rigs[rig].Animate = cnt
		else
			table.insert(AnimationTrack.Rigs[rig].Animations, self)
		end

		for _, v in pairs(rig:GetDescendants()) do
			if boner and v:IsA("Bone") and self.Used[v.Name] then
				AnimationTrack.Rigs[rig].Welds[v.Name] = v
				AnimationTrack.Rigs[rig].Poses[v.Name] = CFrame.new()

				continue
			end

			if v:IsA("Motor6D") and self.Used[v.Part1.Name] then
				local weld = v:FindFirstChild("AWeld")

				if not weld then
					weld = Instance.new("Weld", v)
					weld.C0 = v.C0
					weld.C1 = v.C1
					weld.Name = "AWeld"
					weld.Part0 = v.Part0
					weld.Part1 = v.Part1
				end

				AnimationTrack.Rigs[rig].Welds[v.Part1.Name] = weld
				AnimationTrack.Rigs[rig].Poses[v.Part1.Name] = CFrame.new()
			end
		end

		coroutine.wrap(function()
			repeat
				twait()
			until rig.Parent

			rig.Parent.ChildRemoved:Connect(function(v)
				if v == rig then
					AnimationTrack.Rigs[rig] = nil
					self:Destroy()
				end
			end)
		end)()
	end

	function AnimationTrack.getMotor(self, name)
		if self.Cache[name] then
			return self.Cache[name]
		end

		for _, v in pairs(owner.Character:GetDescendants()) do
			if v:IsA("Motor6D") and v.Part1.Name == name then
				self.Cache[name] = v
				return v
			end
		end
	end

	function AnimationTrack.setAnimation(self, anim)
		local length = 0

		if typeof(anim) == "string" then
			if game:GetService("RunService"):IsClient() then
				error("You must be on server to pass urls to setAnimation!")
			end

			anim = loadstring(http:GetAsync(anim))()
		end

		self.Animation = anim

		local found = {}

		for _, v in pairs(anim) do
			if v.tm > length then
				length = v.tm
			end

			for j, w in pairs(v) do
				if typeof(w) ~= "table" or found[j] then
					if typeof(w) == "string" then
						table.insert(self.KeyframeMarkers, {
							Name = j,
							Value = w,
							Time = v.tm
						})
					end

					continue
				end

				found[j] = true
				self.Used[j] = true
			end
		end
		
		self.Length = length
	end

	function AnimationTrack.IsPrioritized(self, j)
		if not AnimationTrack.Rigs[self.Rig] then
			return
		end

		if not AnimationTrack.Rigs[self.Rig].Animations then
			return
		end

		local highest = 0
		local prioritized

		for _, v in pairs(AnimationTrack.Rigs[self.Rig].Animations) do
			if v.Weight > highest and v.IsPlaying then
				prioritized = v
				highest = v.Weight
			end
		end
		
		if prioritized == self then
			return true
		elseif prioritized ~= self and prioritized then
			if not prioritized.Used[j] then
				local second
				local highest = 0

				for _, v in pairs(AnimationTrack.Rigs[self.Rig].Animations) do
					if v.Weight > highest and v.IsPlaying and v ~= prioritized then
						second = v
						highest = v.Weight
					end
				end

				return second == self
			end
		end
	end

	function AnimationTrack.setCFrame(self, name, cf, info)
		local weld = AnimationTrack.Rigs[self.Rig].Welds[name]
		local poses = AnimationTrack.Rigs[self.Rig].Poses

		if not info then
			AnimationTrack.Rigs[self.Rig].Poses[name] = cf
			weld.C0 = weld.Parent.C0 * cf
		else
			local start = tick()

			while (tick() - start) < info.Time and AnimationTrack.Rigs[self.Rig] and AnimationTrack.Rigs[self.Rig].Poses do
				poses[name] = poses[name]:Lerp(
					cf,
					tween:GetValue((tick() - start) / info.Time, info.EasingStyle, info.EasingDirection)
				)

				weld.C0 = weld.Parent.C0 * poses[name]
				twait()
			end
		end
	end

	function AnimationTrack.goToKeyframe(self, v, inst)
		local speed = self.Speed

		if self.Binds[v] then
			self.Binds[v]:Fire()
		end

		for j, w in pairs(v) do
			if typeof(w) ~= "table" or not AnimationTrack.Rigs[self.Rig].Poses[j] then
				if typeof(w) == "string" and self.Binds[j] then
					self.Binds[j]:Fire(w)
				end

				continue
			end

			if not AnimationTrack.Rigs[self.Rig].Animations then
				break
			end

			if (self:IsPrioritized(j) and inst) and (w.es == "Constant" or inst) then
				if inst and self:IsPrioritized(j) then
					AnimationTrack.Rigs[self.Rig].Poses[j] = w.cf
					continue
				end

				local start = tick()

				coroutine.wrap(function()
					repeat
						AnimationTrack.Rigs[self.Rig].Poses[j] = w.cf
						twait()
					until tick() - start >= (w.tm / speed)
				end)()

				continue
			end

			if not enumExists("EasingStyle", w.es) then
				w.es = "Linear"
			end

			coroutine.wrap(function()
				local s = tick()
				local current = AnimationTrack.Rigs[self.Rig].Poses[j]

				repeat
					twait()

					local cf = current:Lerp(w.cf, tween:GetValue(
						(tick() - s) / (w.tm / speed),
						Enum.EasingStyle[w.es],
						Enum.EasingDirection[w.ed]
					))

					if self:IsPrioritized(j) then
						AnimationTrack.Rigs[self.Rig].Poses[j] = AnimationTrack.Rigs[self.Rig].Poses[j]:Lerp(cf, math.min(self.lerpFactor * math.max(1, speed), 1))
					end
				until (tick() - s) >= (w.tm / speed)
			end)()
		end
	end

	function AnimationTrack.Play(self, speed)
		assert(self.Rig, "Must use setRig before playing!")

		speed = speed or self.Speed

		if self.IsPlaying then
			for _, v in pairs(self.Connections) do
				v:Disconnect()
			end
		end

		self.Speed = speed
		self.IsPlaying = true
		self.Weight = self.RealWeight
		
		self.TimePosition = 0

		-- // just loop through all the keyframes instantly if speed is too high since it'll break
		if (self.Length / self.Speed) <= .1 and #(self.Animation) > 1 then
			coroutine.wrap(function()
				repeat
					twait()

					for _, v in ipairs(self.Animation) do
						self:goToKeyframe(v, true)
						self.TimePosition += v.tm
					end

					self.TimePosition = self.Length
					task.wait(self.Stall)
				until not self.Looped
				
				self:Stop()
			end)()
			
			return
		end

		coroutine.wrap(function()
			repeat
				self.TimePosition = 0

				for _, v in ipairs(self.Animation) do
					local cnt
					local total = 0
					local time = v.tm
					
					cnt = game:GetService("RunService").PreAnimation:Connect(function(dt)
						total += dt * self.Speed
						
						if total >= time then
							cnt:Disconnect()
							self:goToKeyframe(v)
						end
					end)

					table.insert(self.Connections, cnt)
				end

				repeat
					self.TimePosition += twait() * self.Speed
				until self.TimePosition >= (self.Length + (self.Looped and 0 or self.Stall)) or not self.IsPlaying

				if self.TimePosition >= self.Length and not self.Looped then
					self:Stop()
				end
			until not self.Looped or not self.IsPlaying
		end)()
	end

	function AnimationTrack.Stop(self)
		if not self.IsPlaying then
			return
		end

		self.StopBind:Fire()

		self.Weight = 0
		self.IsPlaying = false

		if self.Connections then
			for _, cnt in pairs(self.Connections) do
				cnt:Disconnect()
			end
		end
	end

	function AnimationTrack.AdjustSpeed(self, speed)
		self.Speed = speed or 1
	end
end

return AnimationTrack
