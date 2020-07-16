-- Backwards compatibility

if sm.version:sub(1, 3) == "0.3" then
    dofile("WASD_Converter_0_3.lua")
    return
end




print("Loaded WASD Converters for 0.4")

Converter = class()
Converter.maxChildCount = -1
Converter.maxParentCount = 1
Converter.connectionInput = sm.interactable.connectionType.power
Converter.connectionOutput = sm.interactable.connectionType.logic
Converter.colorNormal = sm.color.new( 0x007fffff )
Converter.colorHighlight = sm.color.new( 0x3094ffff )
Converter.poseWeightCount = 1



--function Converter.client_onFixedUpdate( self, timeStep )
--    self:updateSeat()
--    
--    -- Check if the player is in the parent seat
--    if self:cl_isInSeat() then
--        
--    end
--    
--    self:cl_updateVisuals()
--end
--
--function Converter.cl_isInSeat( self )
--    return self.seat and sm.localPlayer.getPlayer().character == self.seat:getSeatCharacter()
--end

function Converter.sv_setEnabled( self, enabled, power )
    --print(enabled, power)

    self.interactable.power = power
    self.interactable.active = enabled
    
    local shouldAlwaysActive = nil
    for _,v in ipairs(self.interactable:getChildren()) do
        if tostring(v:getType()) == "Controller" then
            if shouldAlwaysActive == nil then
                shouldAlwaysActive = true
            end
        else
            shouldAlwaysActive = false
        end
    end
    if shouldAlwaysActive ~= nil and shouldAlwaysActive == true then
        self.interactable.active = true
    end
end

function Converter.cl_updateVisuals( self )
    self.interactable:setUvFrameIndex(self.interactable.active and 6 or 0)
    self.interactable:setPoseWeight(0, self.interactable.active and 1 or 0)
end

function Converter.updateSeat( self )
    self.seat = self.interactable:getSingleParent()
end

function Converter.calculateEnabled( self )
    self:updateSeat()
    
    print(self.seat)
    if self.seat then
        local value = self.converterFunction(self.seat) * (self.inverted and -1 or 1)
        
        --self:sv_setEnabled(value == (self.inverted and 1 or 0), value * (self.inverted and 1 or -1))
        
        if value == 1 then -- W
            self:sv_setEnabled(true, 1)
        elseif value == -1 then -- S
            self:sv_setEnabled(false, -1)
        else
            self:sv_setEnabled(false, 0.0)
        end
    end
end

function Converter.server_onFixedUpdate( self, timeStep )
    self:calculateEnabled()
end








W_Converter = class( Converter )
A_Converter = class( Converter )
S_Converter = class( Converter )
D_Converter = class( Converter )

function W_Converter.server_onCreate( self )
    self.converterFunction = self.interactable.getSteeringPower
end

function A_Converter.server_onCreate( self )
    self.converterFunction = self.interactable.getSteeringAngle
    self.inverted = true
end

function S_Converter.server_onCreate( self )
    self.converterFunction = self.interactable.getSteeringPower
    self.inverted = true
end

function D_Converter.server_onCreate( self )
    self.converterFunction = self.interactable.getSteeringAngle
end


--[[
function A_Converter.server_onCreate( self )
    self.parentPoseWeight = 0.5
    self.prevParentPoseWeight = 0.5
end
D_Converter.server_onCreate = A_Converter.server_onCreate


function W_Converter.server_onFixedUpdate( self, timeStep )
    if self.seat then
        if self.seat:getSteeringPower() > 0 then -- W
            self:sv_setEnabled(true, 1.0)
        elseif self.seat:getSteeringPower() < 0 then -- S
            self:sv_setEnabled(false, -1.0)
        else
            self:sv_setEnabled(false, 0.0)
        end
    end
end

function A_Converter.server_onFixedUpdate( self, timeStep )
    --print(self.seat, self.seat and self.seat:getSteeringAngle())

    if self.seat then
        if (self.parentPoseWeight < self.prevParentPoseWeight and self.parentPoseWeight < 0.5) or self.parentPoseWeight == 0 then
            --print("A")
            self:sv_setEnabled(true, 1.0)
        elseif (self.parentPoseWeight > self.prevParentPoseWeight and self.parentPoseWeight > 0.5) or self.parentPoseWeight == 1 then
            --print("D")
            self:sv_setEnabled(false, -1.0)
        else
            self:sv_setEnabled(false, 0.0)
        end
        self.prevParentPoseWeight = self.parentPoseWeight
    end
end

function S_Converter.server_onFixedUpdate( self, timeStep )
    if self.seat then
        if self.seat:getSteeringPower() < 0 then -- S
            self:sv_setEnabled(true, 1.0)
        elseif self.seat:getSteeringPower() > 0 then -- W
            self:sv_setEnabled(false, -1.0)
        else
            self:sv_setEnabled(false, 0.0)
        end
    end
end

function D_Converter.server_onFixedUpdate( self, timeStep )
    if self.seat then
        if (self.parentPoseWeight > self.prevParentPoseWeight and self.parentPoseWeight > 0.5) or self.parentPoseWeight == 1 then
            --print("D")
            self:sv_setEnabled(true, 1.0)
        elseif (self.parentPoseWeight < self.prevParentPoseWeight and self.parentPoseWeight < 0.5) or self.parentPoseWeight == 0 then
            --print("A")
            self:sv_setEnabled(false, -1.0)
        else
            self:sv_setEnabled(false, 0.0)
        end
        self.prevParentPoseWeight = self.parentPoseWeight
    end
end
]]