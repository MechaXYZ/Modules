local CameraShaker, CameraShakeInstance, CameraShakePresets

do
	CameraShakeInstance = {}
	CameraShakeInstance.__index = CameraShakeInstance

	local V3 = Vector3.new
	local NOISE = math.noise


	CameraShakeInstance.CameraShakeState = {
		FadingIn = 0;
		FadingOut = 1;
		Sustained = 2;
		Inactive = 3;
	}


	function CameraShakeInstance.new(magnitude, roughness, fadeInTime, fadeOutTime)
		
		if (fadeInTime == nil) then fadeInTime = 0 end
		if (fadeOutTime == nil) then fadeOutTime = 0 end
		
		assert(type(magnitude) == "number", "Magnitude must be a number")
		assert(type(roughness) == "number", "Roughness must be a number")
		assert(type(fadeInTime) == "number", "FadeInTime must be a number")
		assert(type(fadeOutTime) == "number", "FadeOutTime must be a number")
		
		local self = setmetatable({
			Magnitude = magnitude;
			Roughness = roughness;
			PositionInfluence = V3();
			RotationInfluence = V3();
			DeleteOnInactive = true;
			roughMod = 1;
			magnMod = 1;
			fadeOutDuration = fadeOutTime;
			fadeInDuration = fadeInTime;
			sustain = (fadeInTime > 0);
			currentFadeTime = (fadeInTime > 0 and 0 or 1);
			tick = Random.new():NextNumber(-100, 100);
			_camShakeInstance = true;
		}, CameraShakeInstance)
		
		return self
	end


	function CameraShakeInstance:UpdateShake(dt)
		
		local _tick = self.tick
		local currentFadeTime = self.currentFadeTime
		
		local offset = V3(
			NOISE(_tick, 0) * 0.5,
			NOISE(0, _tick) * 0.5,
			NOISE(_tick, _tick) * 0.5
		)
		
		if (self.fadeInDuration > 0 and self.sustain) then
			if (currentFadeTime < 1) then
				currentFadeTime = currentFadeTime + (dt / self.fadeInDuration)
			elseif (self.fadeOutDuration > 0) then
				self.sustain = false
			end
		end
		
		if (not self.sustain) then
			currentFadeTime = currentFadeTime - (dt / self.fadeOutDuration)
		end
		
		if (self.sustain) then
			self.tick = _tick + (dt * self.Roughness * self.roughMod)
		else
			self.tick = _tick + (dt * self.Roughness * self.roughMod * currentFadeTime)
		end
		
		self.currentFadeTime = currentFadeTime
		
		return offset * self.Magnitude * self.magnMod * currentFadeTime
		
	end


	function CameraShakeInstance:StartFadeOut(fadeOutTime)
		if (fadeOutTime == 0) then
			self.currentFadeTime = 0
		end
		self.fadeOutDuration = fadeOutTime
		self.fadeInDuration = 0
		self.sustain = false
	end


	function CameraShakeInstance:StartFadeIn(fadeInTime)
		if (fadeInTime == 0) then
			self.currentFadeTime = 1
		end
		self.fadeInDuration = fadeInTime or self.fadeInDuration
		self.fadeOutDuration = 0
		self.sustain = true
	end


	function CameraShakeInstance:GetScaleRoughness()
		return self.roughMod
	end


	function CameraShakeInstance:SetScaleRoughness(v)
		self.roughMod = v
	end


	function CameraShakeInstance:GetScaleMagnitude()
		return self.magnMod
	end


	function CameraShakeInstance:SetScaleMagnitude(v)
		self.magnMod = v
	end


	function CameraShakeInstance:GetNormalizedFadeTime()
		return self.currentFadeTime
	end


	function CameraShakeInstance:IsShaking()
		return (self.currentFadeTime > 0 or self.sustain)
	end


	function CameraShakeInstance:IsFadingOut()
		return ((not self.sustain) and self.currentFadeTime > 0)
	end


	function CameraShakeInstance:IsFadingIn()
		return (self.currentFadeTime < 1 and self.sustain and self.fadeInDuration > 0)
	end


	function CameraShakeInstance:GetState()
		if (self:IsFadingIn()) then
			return CameraShakeInstance.CameraShakeState.FadingIn
		elseif (self:IsFadingOut()) then
			return CameraShakeInstance.CameraShakeState.FadingOut
		elseif (self:IsShaking()) then
			return CameraShakeInstance.CameraShakeState.Sustained
		else
			return CameraShakeInstance.CameraShakeState.Inactive
		end
	end

	CameraShakePresets = {
		
		
		-- A high-magnitude, short, yet smooth shake.
		-- Should happen once.
		OldBump = function()
			local c = CameraShakeInstance.new(2.5, 4, 0.1, 0.75)
			c.PositionInfluence = Vector3.new(0.15, 0.15, 0.15)
			c.RotationInfluence = Vector3.new(1, 1, 1)
			return c
		end;

		SmallerBump = function()
			local c = CameraShakeInstance.new(4, 8, 0, .5)
			c.PositionInfluence = Vector3.new(0.5, 0.5, 0.5)
			c.RotationInfluence = Vector3.new(4, 2, 2)
			return c
		end;
		
		Bump = function()
			local c = CameraShakeInstance.new(1.5, 20, 0.1, 0.75)
			c.PositionInfluence = Vector3.new(0.15, 0.15, 0.15)
			c.RotationInfluence = Vector3.new(1, 1, 1)
			return c
		end;
		
		-- A very rough, yet low magnitude shake.
		-- Sustained.
		Vibration = function()
			local c = CameraShakeInstance.new(0.4, 20, 0.1, 0.75)
			c.PositionInfluence = Vector3.new(0, 0.15, 0)
			c.RotationInfluence = Vector3.new(1.25, 0, 4)
			return c
		end;
		
		-- A very rough, yet low magnitude shake.
		-- Sustained.
		ViolentShake = function()
			local c = CameraShakeInstance.new(10, 10, 0.1, 0.75)
			c.PositionInfluence = Vector3.new(0, 0.15, 0)
			c.RotationInfluence = Vector3.new(1.25, 0, 4)
			return c
		end;
		
		LongViolentShake = function()
			local c = CameraShakeInstance.new(10, 10, 0.1, 4)
			c.PositionInfluence = Vector3.new(0, 0.15, 0)
			c.RotationInfluence = Vector3.new(1.25, 0, 4)
			return c
		end;

		LongViolentShake2 = function()
			local c = CameraShakeInstance.new(5, 10, 3, 10)
			c.PositionInfluence = Vector3.new(0.45, 0.45, 0.45)
			c.RotationInfluence = Vector3.new(4.5, 1.5, 1.5)
			return c
		end;
		
		-- An intense and rough shake.
		-- Should happen once.
		Explosion = function()
			local c = CameraShakeInstance.new(5, 10, 0, 1.5)
			c.PositionInfluence = Vector3.new(0.25, 0.25, 0.25)
			c.RotationInfluence = Vector3.new(4, 1, 1)
			return c
		end;
		
		Explosion2 = function()
			local c = CameraShakeInstance.new(4, 7, 0, 1)
			c.PositionInfluence = Vector3.new(0.5, 0.5, 0.5)
			c.RotationInfluence = Vector3.new(4, 1, 1)
			return c
		end;
		
		IntenseExplosion = function()
			local c = CameraShakeInstance.new(10, 15, 0, 1)
			c.PositionInfluence = Vector3.new(0.45, 0.45, 0.45)
			c.RotationInfluence = Vector3.new(4.5, 1.5, 1.5)
			return c
		end;

		LongerExplosion = function()
			local c = CameraShakeInstance.new(10, 15, 0, 2.7)
			c.PositionInfluence = Vector3.new(0.45, 0.45, 0.45)
			c.RotationInfluence = Vector3.new(4.5, 1.5, 1.5)
			return c
		end;
		
		LongerExplosion3 = function()
			local c = CameraShakeInstance.new(10, 15, 0, 4)
			c.PositionInfluence = Vector3.new(0.45, 0.45, 0.45)
			c.RotationInfluence = Vector3.new(4.5, 1.5, 1.5)
			return c
		end;

		LongerExplosion2 = function()
			local c = CameraShakeInstance.new(10, 15, 0, 2)
			c.PositionInfluence = Vector3.new(0.45, 0.45, 0.45)
			c.RotationInfluence = Vector3.new(4.5, 1.5, 1.5)
			return c
		end;
		
		
		-- A continuous, rough shake
		-- Sustained.
		Earthquake = function()
			local c = CameraShakeInstance.new(0.6, 3.5, 2, 10)
			c.PositionInfluence = Vector3.new(0.25, 0.25, 0.25)
			c.RotationInfluence = Vector3.new(1, 1, 4)
			return c
		end;
		
		
		-- A bizarre shake with a very high magnitude and low roughness.
		-- Sustained.
		BadTrip = function()
			local c = CameraShakeInstance.new(10, 0.15, 5, 10)
			c.PositionInfluence = Vector3.new(0, 0, 0.15)
			c.RotationInfluence = Vector3.new(2, 1, 4)
			return c
		end;
		
		
		-- A subtle, slow shake.
		-- Sustained.
		HandheldCamera = function()
			local c = CameraShakeInstance.new(1, 0.25, 5, 0.75) -- 0.75 was previously 10
			c.PositionInfluence = Vector3.new(0, 0, 0)
			c.RotationInfluence = Vector3.new(1, 0.5, 0.5)
			return c
		end;
		
		-- A slightly rough, medium magnitude shake.
		-- Sustained.
		RoughDriving = function()
			local c = CameraShakeInstance.new(1, 2, 1, 1)
			c.PositionInfluence = Vector3.new(0, 0, 0)
			c.RotationInfluence = Vector3.new(1, 1, 1)
			return c
		end;
		
		
	}

	local OCSP = CameraShakePresets

	CameraShakePresets = setmetatable({}, {
		__index = function(t, i)
			local f = OCSP[i]
			if (type(f) == "function") then
				return f()
			end
			error("No preset found with index \"" .. i .. "\"")
		end;
	})

	CameraShaker = {}
	CameraShaker.__index = CameraShaker

	local V3 = Vector3.new
	local CF = CFrame.new
	local ANG = CFrame.Angles
	local RAD = math.rad
	local v3Zero = V3()

	local CameraShakeState = CameraShakeInstance.CameraShakeState

	local defaultPosInfluence = V3(0.15, 0.15, 0.15)
	local defaultRotInfluence = V3(1, 1, 1)


	CameraShaker.CameraShakeInstance = CameraShakeInstance
	CameraShaker.Presets = CameraShakePresets


	function CameraShaker.new(renderPriority, callback)
		assert(type(renderPriority) == "number", "RenderPriority must be a number (e.g.: Enum.RenderPriority.Camera.Value)")
		assert(type(callback) == "function", "Callback must be a function")
		
		local self = setmetatable({
			_running = false;
			_renderName = "CameraShaker";
			_renderPriority = renderPriority;
			_posAddShake = v3Zero;
			_rotAddShake = v3Zero;
			_camShakeInstances = {};
			_removeInstances = {};
			_callback = callback;
		}, CameraShaker)
		
		return self
		
	end


	function CameraShaker:Start()
		if (self._running) then return end
		self._running = true
		local callback = self._callback
		game:GetService("RunService"):BindToRenderStep(self._renderName, self._renderPriority, function(dt)
			local cf = self:Update(dt)
			callback(cf)
		end)
	end


	function CameraShaker:Stop()
		if (not self._running) then return end
		game:GetService("RunService"):UnbindFromRenderStep(self._renderName)
		self._running = false
	end


	function CameraShaker:StopSustained(duration)
		for _,c in pairs(self._camShakeInstances) do
			if (c.fadeOutDuration == 0) then
				c:StartFadeOut(duration or c.fadeInDuration)
			end
		end
	end


	function CameraShaker:Update(dt)
		
		local posAddShake = v3Zero
		local rotAddShake = v3Zero
		
		local instances = self._camShakeInstances
		
		-- Update all instances:
		for i = 1,#instances do
			
			local c = instances[i]
			local state = c:GetState()
			
			if (state == CameraShakeState.Inactive and c.DeleteOnInactive) then
				self._removeInstances[#self._removeInstances + 1] = i
			elseif (state ~= CameraShakeState.Inactive) then
				local shake = c:UpdateShake(dt)
				posAddShake = posAddShake + (shake * c.PositionInfluence)
				rotAddShake = rotAddShake + (shake * c.RotationInfluence)
			end
			
		end
		
		
		-- Remove dead instances:
		for i = #self._removeInstances,1,-1 do
			local instIndex = self._removeInstances[i]
			table.remove(instances, instIndex)
			self._removeInstances[i] = nil
		end
		
		return CF(posAddShake) *
				ANG(0, RAD(rotAddShake.Y), 0) *
				ANG(RAD(rotAddShake.X), 0, RAD(rotAddShake.Z))
		
	end


	function CameraShaker:Shake(shakeInstance)
		assert(type(shakeInstance) == "table" and shakeInstance._camShakeInstance, "ShakeInstance must be of type CameraShakeInstance")
		self._camShakeInstances[#self._camShakeInstances + 1] = shakeInstance
		return shakeInstance
	end


	function CameraShaker:ShakeSustain(shakeInstance)
		assert(type(shakeInstance) == "table" and shakeInstance._camShakeInstance, "ShakeInstance must be of type CameraShakeInstance")
		self._camShakeInstances[#self._camShakeInstances + 1] = shakeInstance
		shakeInstance:StartFadeIn(shakeInstance.fadeInDuration)
		return shakeInstance
	end


	function CameraShaker:ShakeOnce(magnitude, roughness, fadeInTime, fadeOutTime, posInfluence, rotInfluence)
		local shakeInstance = CameraShakeInstance.new(magnitude, roughness, fadeInTime, fadeOutTime)
		shakeInstance.PositionInfluence = (typeof(posInfluence) == "Vector3" and posInfluence or defaultPosInfluence)
		shakeInstance.RotationInfluence = (typeof(rotInfluence) == "Vector3" and rotInfluence or defaultRotInfluence)
		self._camShakeInstances[#self._camShakeInstances + 1] = shakeInstance
		return shakeInstance
	end


	function CameraShaker:StartShake(magnitude, roughness, fadeInTime, posInfluence, rotInfluence)
		local shakeInstance = CameraShakeInstance.new(magnitude, roughness, fadeInTime)
		shakeInstance.PositionInfluence = (typeof(posInfluence) == "Vector3" and posInfluence or defaultPosInfluence)
		shakeInstance.RotationInfluence = (typeof(rotInfluence) == "Vector3" and rotInfluence or defaultRotInfluence)
		shakeInstance:StartFadeIn(fadeInTime)
		self._camShakeInstances[#self._camShakeInstances + 1] = shakeInstance
		return shakeInstance
	end
end

return CameraShaker, CameraShakeInstance, CameraShakePresets
