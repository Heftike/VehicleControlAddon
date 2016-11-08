--
-- keyboardSteerMogli
-- This is the specialization for keyboardSteerMogli
--

--***************************************************************
source(Utils.getFilename("mogliBase.lua", g_currentModDirectory))
_G[g_currentModName..".mogliBase"].newClass( "keyboardSteerMogli" )
--***************************************************************

function keyboardSteerMogli.globalsReset( createIfMissing )
	KSMGlobals                   = {}
	KSMGlobals.cameraRotFactor     = 0
	KSMGlobals.cameraRotFactorRev  = 0
	KSMGlobals.cameraRotTime       = 0
	KSMGlobals.speedFxPoint1       = 0
	KSMGlobals.speedFxPoint2       = 0
	KSMGlobals.speedFxPoint3       = 0
	KSMGlobals.autoRotateBackFx0   = 0
	KSMGlobals.autoRotateBackFx1   = 0
	KSMGlobals.autoRotateBackFx2   = 0
	KSMGlobals.autoRotateBackFx3   = 0
	KSMGlobals.autoRotateBackFxMax = 0
	KSMGlobals.axisSideFx0         = 0
	KSMGlobals.axisSideFx1         = 0
	KSMGlobals.axisSideFx2         = 0
	KSMGlobals.axisSideFx3         = 0
	KSMGlobals.axisSideFxMax       = 0
	KSMGlobals.maxRotTimeFx0       = 0
	KSMGlobals.maxRotTimeFx1       = 0
	KSMGlobals.maxRotTimeFx2       = 0
	KSMGlobals.maxRotTimeFx3       = 0
	KSMGlobals.maxRotTimeFxMax     = 0
  KSMGlobals.maxSpeed4Fx	       = 0
  KSMGlobals.timer4Reverse       = 0
  KSMGlobals.minSpeed4Fx	       = 0
  KSMGlobals.speedFxInc          = 0
	KSMGlobals.enableAnalogCtrl    = false
	KSMGlobals.debugPrint          = false
	
-- defaults	
  KSMGlobals.ksmSteeringIsOn  = false
  KSMGlobals.ksmCameraIsOn    = false
  KSMGlobals.ksmCamInsideIsOn = false
  KSMGlobals.ksmDrawIsOn      = false
	KSMGlobals.ksmReverseIsOn   = false
	
	local file
	file = keyboardSteerMogli.baseDirectory.."keyboardSteerMogliConfig.xml"
	if fileExists(file) then	
		keyboardSteerMogli.globalsLoad( file, "KSMGlobals", KSMGlobals )	
	else
		print("ERROR: NO GLOBALS IN "..file)
	end
	
	file = keyboardSteerMogli.modsDirectory.."keyboardSteerMogliConfig.xml"
	if fileExists(file) then	
		keyboardSteerMogli.globalsLoad( file, "KSMGlobals", KSMGlobals )	
	elseif createIfMissing then
		keyboardSteerMogli.globalsCreate()
	end
	
	KSMGlobals.autoRotateBackFx = AnimCurve:new(linearInterpolator1)
	KSMGlobals.axisSideFx       = AnimCurve:new(linearInterpolator1)
	KSMGlobals.maxRotTimeFx     = AnimCurve:new(linearInterpolator1)
	
	KSMGlobals.autoRotateBackFx:addKeyframe({v=KSMGlobals.autoRotateBackFx0, time = 0})
	KSMGlobals.autoRotateBackFx:addKeyframe({v=KSMGlobals.autoRotateBackFx1, time = KSMGlobals.speedFxPoint1/KSMGlobals.maxSpeed4Fx})
	KSMGlobals.autoRotateBackFx:addKeyframe({v=KSMGlobals.autoRotateBackFx2, time = KSMGlobals.speedFxPoint2/KSMGlobals.maxSpeed4Fx})
	KSMGlobals.autoRotateBackFx:addKeyframe({v=KSMGlobals.autoRotateBackFx3, time = KSMGlobals.speedFxPoint3/KSMGlobals.maxSpeed4Fx})
	KSMGlobals.autoRotateBackFx:addKeyframe({v=KSMGlobals.autoRotateBackFxMax, time = 1})
	
	KSMGlobals.axisSideFx:addKeyframe({v=KSMGlobals.axisSideFx0, time = 0})
	KSMGlobals.axisSideFx:addKeyframe({v=KSMGlobals.axisSideFx1, time = KSMGlobals.speedFxPoint1/KSMGlobals.maxSpeed4Fx})
	KSMGlobals.axisSideFx:addKeyframe({v=KSMGlobals.axisSideFx2, time = KSMGlobals.speedFxPoint2/KSMGlobals.maxSpeed4Fx})
	KSMGlobals.axisSideFx:addKeyframe({v=KSMGlobals.axisSideFx3, time = KSMGlobals.speedFxPoint3/KSMGlobals.maxSpeed4Fx})
	KSMGlobals.axisSideFx:addKeyframe({v=KSMGlobals.axisSideFxMax, time = 1})

	KSMGlobals.maxRotTimeFx:addKeyframe({v=KSMGlobals.maxRotTimeFx0, time = 0})
	KSMGlobals.maxRotTimeFx:addKeyframe({v=KSMGlobals.maxRotTimeFx1, time = KSMGlobals.speedFxPoint1/KSMGlobals.maxSpeed4Fx})
	KSMGlobals.maxRotTimeFx:addKeyframe({v=KSMGlobals.maxRotTimeFx2, time = KSMGlobals.speedFxPoint2/KSMGlobals.maxSpeed4Fx})
	KSMGlobals.maxRotTimeFx:addKeyframe({v=KSMGlobals.maxRotTimeFx3, time = KSMGlobals.speedFxPoint3/KSMGlobals.maxSpeed4Fx})
	KSMGlobals.maxRotTimeFx:addKeyframe({v=KSMGlobals.maxRotTimeFxMax, time = 1})
		
	print("keyboardSteerMogli initialized");
end

keyboardSteerMogli.globalsReset(false)

function keyboardSteerMogli.debugPrint( ... )
	if KSMGlobals.debugPrint then
		print( ... )
	end
end

function keyboardSteerMogli:isValidCam( index, createIfMissing )
	local i = Utils.getNoNil( index, self.camIndex )
	
	if      self.cameras ~= nil 
			and i ~= nil 
			and self.cameras[i] ~= nil 
			and self.cameras[i].vehicle == self
			and self.cameras[i].isRotatable then
		if self.ksmCameras[i] == nil then
			if createIfMissing then
				self.ksmCameras[i] = { rotation = keyboardSteerMogli.getDefaultRotation( self, i ),
															 rev      = keyboardSteerMogli.getDefaultReverse( self, i ),
															 zero     = self.cameras[i].rotY,
															 last     = self.cameras[i].rotY }
			else
				return false
			end
		end
		return true
	end
	
	return false
end

function keyboardSteerMogli:load(savegame)

	self.ksmScaleFx       = keyboardSteerMogli.scaleFx
	self.ksmSetState      = keyboardSteerMogli.mbSetState
	self.ksmIsValidCam    = keyboardSteerMogli.isValidCam

	keyboardSteerMogli.registerState( self, "ksmSteeringIsOn", false )
	keyboardSteerMogli.registerState( self, "ksmAnalogIsOn",   false )
	keyboardSteerMogli.registerState( self, "ksmLastCamIndex", 0,     keyboardSteerMogli.ksmOnSetCamIndex )
	keyboardSteerMogli.registerState( self, "ksmCameraIsOn"  , false, keyboardSteerMogli.ksmOnSetCamera )
	keyboardSteerMogli.registerState( self, "ksmReverseIsOn" , false, keyboardSteerMogli.ksmOnSetReverse )
	keyboardSteerMogli.registerState( self, "ksmCamFwd"      , true , keyboardSteerMogli.ksmOnSetCamFwd )
	keyboardSteerMogli.registerState( self, "ksmExponent"    , 1    , keyboardSteerMogli.ksmOnSetFactor )
	keyboardSteerMogli.registerState( self, "ksmWarningText" , ""   , keyboardSteerMogli.ksmOnSetWarningText )
	keyboardSteerMogli.registerState( self, "ksmLCtrlPressed", false )
	keyboardSteerMogli.registerState( self, "ksmLShiftPressed", false )
	
	self.ksmSpeedFx       = 0
	self.ksmFactor        = 1
	self.ksmSpeedFxMin    = KSMGlobals.minSpeed4Fx / ( KSMGlobals.maxSpeed4Fx - KSMGlobals.minSpeed4Fx )
	self.ksmSpeedFxFactor = 3600 / ( KSMGlobals.maxSpeed4Fx - KSMGlobals.minSpeed4Fx )
	self.ksmReverseTimer  = 1.5 / KSMGlobals.timer4Reverse
	self.ksmMovingDir     = 0
	self.ksmLastFactor    = 0
	self.ksmWarningTimer  = 0
	self.ksmLCtrlPressed  = false
	self.ksmLShiftPressed = false

	if KSMGlobals.ksmSteeringIsOn then
		self:ksmSetState( "ksmSteeringIsOn", true, true )
	end
	if KSMGlobals.enableAnalogCtrl then
		self:ksmSetState( "ksmAnalogIsOn", true, true )
	end
	
	self.ksmCameras = {}
	
	for i,c in pairs(self.cameras) do
		self:ksmIsValidCam( i, true )
	end	
end

function keyboardSteerMogli:update(dt)

	local lastCamIndex = self.ksmLastCamIndex
	if      self:getIsActive() 
			and self.cameras ~= nil 
			and self.camIndex ~= nil then
		self:ksmSetState( "ksmLastCamIndex", self.camIndex )
	end

	if self.isEntered and self.isClient and self:getIsActive() then
		if     InputBinding.hasEvent(InputBinding.ksmPLUS) then
			self:ksmSetState( "ksmExponent", self.ksmExponent +1 )
			self:ksmSetState( "ksmWarningText", string.format("Sensitivity %3.0f %%", 100 * self.ksmFactor, true ) )
		elseif InputBinding.hasEvent(InputBinding.ksmMINUS) then
			self:ksmSetState( "ksmExponent", self.ksmExponent -1 )
			self:ksmSetState( "ksmWarningText", string.format("Sensitivity %3.0f %%", 100 * self.ksmFactor, true ) )
		elseif InputBinding.hasEvent(InputBinding.ksmENABLE) then		
			self:ksmSetState( "ksmSteeringIsOn", not self.ksmSteeringIsOn )
		elseif InputBinding.hasEvent(InputBinding.ksmCAMERA) then
			self:ksmSetState( "ksmCameraIsOn", not self.ksmCameraIsOn )
		elseif InputBinding.hasEvent(InputBinding.ksmREVERSE) then
			self:ksmSetState( "ksmReverseIsOn", not self.ksmReverseIsOn )
		elseif InputBinding.hasEvent(InputBinding.ksmANALOG) then
			self:ksmSetState( "ksmAnalogIsOn", not self.ksmAnalogIsOn )
		end
		
		local newRot = nil
		if     InputBinding.hasEvent(InputBinding.ksmUP)    then
			newRot = 0
		elseif InputBinding.hasEvent(InputBinding.ksmDOWN)  then
			newRot = math.pi
		elseif InputBinding.hasEvent(InputBinding.ksmLEFT)  then
			newRot = 0.3*math.pi
		elseif InputBinding.hasEvent(InputBinding.ksmRIGHT) then
			newRot = -0.3*math.pi
		end
		
		if      newRot ~= nil 
				and self:ksmIsValidCam() then
			local diff = self.cameras[self.camIndex].rotY - self.ksmCameras[self.camIndex].last
			self.cameras[self.camIndex].rotY = keyboardSteerMogli.normalizeAngle( self.cameras[self.camIndex].origRotY + newRot )
		end
	end

	if self:getIsActive() and self.isServer then
		local deltaFx      = math.max( self.lastSpeed * self.ksmSpeedFxFactor - self.ksmSpeedFxMin, 0 )  - self.ksmSpeedFx
		self.ksmSpeedFx    = math.min( self.ksmSpeedFx + KSMGlobals.speedFxInc * deltaFx, 1 )

		if      self.mrGbMS ~= nil
				and self.mrGbMS.IsOn then
			if self.mrGbMS.ReverseActive then
				self.ksmMovingDir = -1
			else
				self.ksmMovingDir = 1
			end
		elseif  self.dCcheckModule        ~=  nil 
				and self.driveControl         ~= nil
				and self:dCcheckModule("shuttle")
				and self.driveControl.shuttle ~= nil 
				and self.driveControl.shuttle.isActive 
				and self.driveControl.shuttle.direction ~= nil 
				and self.driveControl.shuttle.isActive then
			self.ksmMovingDir = self.driveControl.shuttle.direction * self.reverserDirection
		else
			local movingDirection = self.movingDirection * self.reverserDirection
			if math.abs( self.lastSpeed ) < 0.00054 then
				movingDirection = 0
			end
					
			local maxDelta    = dt * self.ksmReverseTimer
			self.ksmMovingDir = self.ksmMovingDir + Utils.clamp( movingDirection - self.ksmMovingDir, -maxDelta, maxDelta )
		
		end
			
		if     self.ksmMovingDir < -0.5 then
			self:ksmSetState( "ksmCamFwd", false )
		elseif self.ksmMovingDir >  0.5 then
			self:ksmSetState( "ksmCamFwd", true )
		else
			fwd = self.ksmCamFwd
		end		
	end
	
	if      self:getIsActive() 
			and self.steeringEnabled
			and self.ksmCameraIsOn 
			and self:ksmIsValidCam() then

	--local _,oldRotY,_ = getRotation( self.cameras[self.camIndex].rotationNode )
		oldRotY = self.cameras[self.camIndex].rotY
		local diff = oldRotY - self.ksmCameras[self.camIndex].last
		self.ksmCameras[self.camIndex].zero   = self.ksmCameras[self.camIndex].zero + diff
			
		local newRotY = self.ksmCameras[self.camIndex].zero
		diff = math.abs( keyboardSteerMogli.getAbsolutRotY( self, self.camIndex ) )
		local isRev = false
		if diff <  0.55* math.pi then
			isRev = true
		end
		
		local f = 0
		if     self.rotatedTime > 0 then
			f = self.rotatedTime / self.maxRotTime
		elseif self.rotatedTime < 0 then
			f = self.rotatedTime / self.minRotTime
		end
		if f < 0.1 then
			f = 0
		else
			f = 1.2345679 * ( f - 0.1 ) ^2 / 0.81
		--f = 1.1111111 * ( f - 0.1 )
		end
		if self.rotatedTime < 0 then
			f = -f
		end
		
		local g = self.ksmLastFactor
		self.ksmLastFactor = self.ksmLastFactor + Utils.clamp( f - self.ksmLastFactor, -KSMGlobals.cameraRotTime*dt, KSMGlobals.cameraRotTime*dt )
		if math.abs( self.ksmLastFactor - g ) > 0.01 then
			f = self.ksmLastFactor
		else
			f = g
		end
		
		if isRev then
		--print("reverse")
			newRotY = newRotY - self:ksmScaleFx( KSMGlobals.cameraRotFactorRev, 0.1, 3 ) * f
		else
		--print("forward")
			newRotY = newRotY + self:ksmScaleFx( KSMGlobals.cameraRotFactor, 0.1, 3 ) * f
		end		
	
		self.cameras[self.camIndex].rotY    = newRotY
		self.ksmCameras[self.camIndex].last = self.cameras[self.camIndex].rotY
		
	else
		self.ksmLastFactor = 0
	end	

	self.ksmWarningTimer = self.ksmWarningTimer - dt
	
	if      self:getIsActive()
			and self.ksmWarningText ~= nil
			and self.ksmWarningText ~= "" then
		if self.ksmWarningTimer <= 0 then
			self.ksmWarningText = ""
		end
	end
end

function keyboardSteerMogli:readStream(streamId, connection)

  self.ksmSteeringIsOn = streamReadBool(streamId) 
  self.ksmCameraIsOn   = streamReadBool(streamId) 
  self.ksmReverseIsOn  = streamReadBool(streamId) 
  self.ksmCamFwd       = streamReadBool(streamId) 
	self.ksmExponent     = streamReadInt16(streamId)     
	
end

function keyboardSteerMogli:writeStream(streamId, connection)

	streamWriteBool(streamId, self.ksmSteeringIsOn )
	streamWriteBool(streamId, self.ksmCameraIsOn )
	streamWriteBool(streamId, self.ksmReverseIsOn )
	streamWriteBool(streamId, self.ksmCamFwd )     
	streamWriteInt16(streamId,self.ksmExponent )     

end

function keyboardSteerMogli:keyEvent(unicode, sym, modifier, isDown)
	if sym == Input.KEY_lctrl then
		self:ksmSetState( "ksmLCtrlPressed", isDown )
	end
	if sym == Input.KEY_lshift then
		self:ksmSetState( "ksmLShiftPressed", isDown )
	end
end

function keyboardSteerMogli:onLeave()
	self:ksmSetState( "ksmLCtrlPressed", false )
	self:ksmSetState( "ksmLShiftPressed", false )
end

function keyboardSteerMogli:draw()		
	if self.ksmLCtrlPressed then
		if self.ksmLShiftPressed then
			if self.ksmAnalogIsOn then
				g_currentMission:addHelpButtonText(keyboardSteerMogli.getText("ksmANALOG_ON"),  InputBinding.ksmANALOG)
			else
				g_currentMission:addHelpButtonText(keyboardSteerMogli.getText("ksmANALOG_OFF"), InputBinding.ksmANALOG)
			end
		else
			g_currentMission:addHelpButtonText(keyboardSteerMogli.getText("input_ksmPLUS"),  InputBinding.ksmPLUS)
			g_currentMission:addHelpButtonText(keyboardSteerMogli.getText("input_ksmMINUS"), InputBinding.ksmMINUS)
		end
		
	elseif KSMGlobals.ksmDrawIsOn or self.ksmLShiftPressed then
		if self.ksmSteeringIsOn then
			g_currentMission:addHelpButtonText(keyboardSteerMogli.getText("ksmENABLE_ON"),  InputBinding.ksmENABLE)
		else
			g_currentMission:addHelpButtonText(keyboardSteerMogli.getText("ksmENABLE_OFF"), InputBinding.ksmENABLE)
		end
		
		if self:ksmIsValidCam() then
			if self.ksmCameraIsOn then
				g_currentMission:addHelpButtonText(keyboardSteerMogli.getText("ksmCAMERA_ON"),  InputBinding.ksmCAMERA)
			else
				g_currentMission:addHelpButtonText(keyboardSteerMogli.getText("ksmCAMERA_OFF"), InputBinding.ksmCAMERA)
			end
			if self.ksmReverseIsOn then
				g_currentMission:addHelpButtonText(keyboardSteerMogli.getText("ksmREVERSE_ON"),  InputBinding.ksmREVERSE)
			else
				g_currentMission:addHelpButtonText(keyboardSteerMogli.getText("ksmREVERSE_OFF"), InputBinding.ksmREVERSE)
			end
		end
	end
	if self.ksmWarningText ~= "" then
		g_currentMission:addExtraPrintText( self.ksmWarningText )
	end
end  

function keyboardSteerMogli:getDefaultRotation( camIndex )
	if     self.cameras           == nil
			or self.cameras[camIndex] == nil then
		keyboardSteerMogli.debugPrint( "invalid camera" )
		return false
	elseif not ( self.cameras[camIndex].isRotatable )
			or self.cameras[camIndex].vehicle ~= self then
		keyboardSteerMogli.debugPrint( "fixed camera" )
		return false
	elseif  KSMGlobals.ksmCamInsideIsOn 
			and self.cameras[camIndex].isInside then
		keyboardSteerMogli.debugPrint( "camera is inside" )
		return true
	end
	keyboardSteerMogli.debugPrint( "other camera: "..tostring(KSMGlobals.ksmCameraIsOn) )
	return KSMGlobals.ksmCameraIsOn
end

function keyboardSteerMogli:getDefaultReverse( camIndex )
	if     self.cameras           == nil
			or self.cameras[camIndex] == nil then
		return false
	elseif not ( self.cameras[camIndex].isRotatable )
			or self.cameras[camIndex].vehicle ~= self then
		return false
	elseif  self.cameras[camIndex].isInside
			and SpecializationUtil.hasSpecialization(Combine, self.specializations) then
		return false
	end
	
	if self.attacherJoints ~= nil then
		for _,a in pairs( self.attacherJoints ) do
			if a.jointType == JOINTTYPE_SEMITRAILER then
				return false
			end
		end
	end
	
	return KSMGlobals.ksmReverseIsOn
end

function keyboardSteerMogli:getSaveAttributesAndNodes(nodeIdent)
	local attributes = ""
	if self.ksmSteeringIsOn ~= nil and self.ksmSteeringIsOn ~= KSMGlobals.ksmSteeringIsOn then
		attributes = attributes.." ksmSteeringIsOn=\""  .. tostring(self.ksmSteeringIsOn) .. "\""
	end
	if self.ksmAnalogIsOn ~= nil and self.ksmAnalogIsOn ~= KSMGlobals.enableAnalogCtrl then
		attributes = attributes.." ksmAnalogIsOn=\""  .. tostring(self.ksmAnalogIsOn) .. "\""
	end
	
	for i,b in pairs(self.ksmCameras) do
		if b.rotation ~= keyboardSteerMogli.getDefaultRotation( self, i ) then
			attributes = attributes.." ksmCameraIsOn_"..tostring(i).."=\""  .. tostring(b.rotation) .. "\""
		end
		if b.rev ~= keyboardSteerMogli.getDefaultReverse( self, i ) then
			attributes = attributes.." ksmReverseIsOn_"..tostring(i).."=\""  .. tostring(b.rev) .. "\""
		end
	end
	if self.ksmExponent ~= nil and math.abs( self.ksmExponent - 1 ) > 1E-3 then
		attributes = attributes.." ksmExponent=\""  .. tostring(self.ksmExponent) .. "\""
	end

	return attributes
end;

function keyboardSteerMogli:loadFromAttributesAndNodes(xmlFile, key, resetVehicles)

	local b = getXMLBool(xmlFile, key .. "#ksmSteeringIsOn" )
	if b ~= nil then
		self:ksmSetState( "ksmSteeringIsOn", b,  true ) 
	end
	b = getXMLBool(xmlFile, key .. "#ksmAnalogIsOn" )
	if b ~= nil then
		self.ksmAnalogIsOn = b
	end
	
	if self.ksmCameras == nil then
		self.ksmCameras = {}
	end
	
	for i,c in pairs(self.cameras) do
		if self:ksmIsValidCam( i, true ) then
			b = getXMLBool(xmlFile, key .. "#ksmCameraIsOn_"..tostring(i) )
			if b ~= nil then
				self.ksmCameras[i].rotation = b
			end
			b = getXMLBool(xmlFile, key .. "#ksmReverseIsOn_"..tostring(i) )
			if b ~= nil then
				self.ksmCameras[i].rev      = b
			end
		end
	end
	
	local i = getXMLInt(xmlFile, key .. "#ksmExponent" )
	if i ~= nil then
		self:ksmSetState( "ksmExponent", i,  true ) 
	end
	
	return BaseMission.VEHICLE_LOAD_OK;
end

function keyboardSteerMogli:scaleFx( fx, mi, ma )
	return Utils.clamp( 1 + self.ksmFactor * ( fx - 1 ), mi, ma )
end

function keyboardSteerMogli:newUpdateVehiclePhysics( superFunc, axisForward, axisForwardIsAnalog, axisSide, axisSideIsAnalog, doHandbrake, dt, ... )
	local backup1 = self.autoRotateBackSpeed
	local backup2 = self.minRotTime
	local backup3 = self.maxRotTime
	if self.ksmSteeringIsOn and ( self.ksmAnalogIsOn or not ( axisSideIsAnalog ) ) then
		local arbs = backup1
		
		if self.lastSpeed < 0.000278 then
			self.autoRotateBackSpeed = 0
		elseif self.rotatedTime >= 0 then
			self.autoRotateBackSpeed = ( 0.2 + 0.8 * self.rotatedTime / self.maxRotTime ) * self:ksmScaleFx( KSMGlobals.autoRotateBackFx:get( self.ksmSpeedFx ), 0.1, 3 ) * arbs
		else                                                      
			self.autoRotateBackSpeed = ( 0.2 + 0.8 * self.rotatedTime / self.minRotTime ) * self:ksmScaleFx( KSMGlobals.autoRotateBackFx:get( self.ksmSpeedFx ), 0.1, 3 ) * arbs
		end
		
		local f = self:ksmScaleFx( KSMGlobals.maxRotTimeFx:get( self.ksmSpeedFx ), 0, 1 )
		
		self.minRotTime = f * backup2
		self.maxRotTime = f * backup3
		
		axisSide = self:ksmScaleFx( KSMGlobals.axisSideFx:get( self.ksmSpeedFx ), 0.1, 3 ) * axisSide
		if axisSide > 0 and self.rotatedTime > 0 then
			axisSide = math.max( axisSide, self.autoRotateBackSpeed )
		end
		if axisSide < 0 and self.rotatedTime < 0 then
			axisSide = math.min( axisSide, -self.autoRotateBackSpeed )
		end
	end
	
	if      self.ksmSteeringIsOn 
			and self.ksmLShiftPressed 
			and ( self.ksmAnalogIsOn or not ( axisForwardIsAnalog ) ) then
		axisForward = Utils.clamp( axisForward, -0.75, 0.75 )
		axisForwardIsAnalog = true
	end
	
	local state, result = pcall( superFunc, self, axisForward, axisForwardIsAnalog, axisSide, axisSideIsAnalog, doHandbrake, dt, ... )
	if not ( state ) then
		print("Error in updateVehiclePhysics :"..tostring(result))
	end

	self.autoRotateBackSpeed = backup1
	self.minRotTime          = backup2
	self.maxRotTime          = backup3
end

function keyboardSteerMogli:ksmOnSetCamera( old, new, noEventSend ) 
	self.ksmCameraIsOn = new
	if      self.ksmLastCamIndex ~= nil
			and self:ksmIsValidCam( self.ksmLastCamIndex ) then
		self.ksmCameras[self.ksmLastCamIndex].rotation = new
	end
	if new and not ( old ) then
		for i,c in pairs(self.cameras) do
			if self:ksmIsValidCam( i ) then
				self.ksmCameras[i].zero = c.rotY
				self.ksmCameras[i].last = c.rotY
			end
		end
	elseif old and not ( new ) then
		for i=1,table.getn(self.cameras) do
			if self:ksmIsValidCam( i ) and self.ksmCameras[i].zero ~= nil then
				self.cameras[i].rotY = self.ksmCameras[i].zero
			end
		end
	end
end

function keyboardSteerMogli:ksmOnSetReverse( old, new, noEventSend ) 
	self.ksmReverseIsOn = new
	if      self.ksmLastCamIndex ~= nil
			and self:ksmIsValidCam( self.ksmLastCamIndex ) then
		self.ksmCameras[self.ksmLastCamIndex].rev = new
	end
end

function keyboardSteerMogli:ksmOnSetCamFwd( old, new, noEventSend ) 
	if self.ksmCamFwd ~= new then
		self.ksmCamFwd = new
		keyboardSteerMogli.ksmSetCameraFwd( self, new )
	end
end

function keyboardSteerMogli:ksmSetCameraFwd( camFwd ) 
	if      self.steeringEnabled
			and camFwd                             ~= nil
			and self.ksmLastCamIndex               ~= nil 
			and self:ksmIsValidCam( self.ksmLastCamIndex ) then
		local pi2 = math.pi / 2
		local i   = self.ksmLastCamIndex
		local rev = KSMGlobals.ksmReverseIsOn 
		if self.ksmCameras[i] ~= nil then
			rev = self.ksmCameras[i].rev
		end
		if self.cameras[i].isRotatable and rev then
			local diff = math.abs( keyboardSteerMogli.getAbsolutRotY( self, i ) )
			local inv  = false
			if camFwd then
				inv = diff < pi2
			else
				inv = diff > pi2
			end
			if inv then
				self.cameras[i].rotY      = keyboardSteerMogli.normalizeAngle( self.cameras[i].rotY + math.pi )
			--self.ksmCameras[i].last   = self.cameras[i].rotY
			--if self.ksmCameras[i].zero ~= nil then
			--	self.ksmCameras[i].zero = keyboardSteerMogli.normalizeAngle( self.ksmCameras[i].zero + math.pi )
			--end
			end
		end
	end
end

----********************************
---- normalizeAngle
----********************************
--function keyboardSteerMogli.normalizeAngle( angle )
--	local normalizedAngle = angle
--	if angle >= math.pi+math.pi then
--		normalizedAngle = angle - math.pi - math.pi
--	elseif angle < 0 then
--		normalizedAngle = angle + math.pi + math.pi
--	end
--	return normalizedAngle
--end


function keyboardSteerMogli:ksmOnSetFactor( old, new, noEventSend )
	self.ksmExponent = new
	self.ksmFactor   = 1.1 ^ new
end

function keyboardSteerMogli:ksmOnSetWarningText( old, new, noEventSend )
	self.ksmWarningText  = new
  self.ksmWarningTimer = 2000
end

function keyboardSteerMogli:ksmOnSetCamIndex( old, new, noEventSend )
	self.ksmLastCamIndex = new
	if      self.cameras ~= nil 
			and new ~= nil 
			and ( old == nil or old ~= new )
			and self:ksmIsValidCam( new, true ) then
		if old ~= nil then
			if self:ksmIsValidCam( old ) and self.ksmCameras[old].zero ~= nil then
				self.cameras[old].rotY = self.ksmCameras[old].zero
			end
		end
		
		keyboardSteerMogli.ksmSetCameraFwd( self, self.ksmCamFwd )
		if self.ksmCameras[new].rotation ~= self.ksmCameraIsOn then
			self:ksmSetState( "ksmCameraIsOn", self.ksmCameras[new].rotation, true )
		end
		if self.ksmCameras[new].rev ~= self.ksmReverseIsOn then
			self:ksmSetState( "ksmReverseIsOn", self.ksmCameras[new].rev, true )
		end
	end
end

function keyboardSteerMogli:getAbsolutRotY( camIndex )
	if     self.cameras == nil
			or self.cameras[camIndex] == nil then
		return 0
	end
  return keyboardSteerMogli.getRelativeYRotation( self.cameras[camIndex].cameraNode, self.steeringCenterNode )
end

function keyboardSteerMogli.getRelativeYRotation(root,node)
	if root == nil or node == nil then
		return 0
	end
	local x, y, z = worldDirectionToLocal(node, localDirectionToWorld(root, 0, 0, 1))
	local dot = z
	dot = dot / Utils.vector2Length(x, z)
	local angle = math.acos(dot)
	if x < 0 then
		angle = -angle
	end
	return angle
end


Drivable.updateVehiclePhysics = Utils.overwrittenFunction( Drivable.updateVehiclePhysics, keyboardSteerMogli.newUpdateVehiclePhysics )

