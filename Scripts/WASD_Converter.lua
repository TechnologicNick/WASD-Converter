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



function Converter.sv_setEnabled( self, enabled, power )
    self.interactable.power = power
    self.interactable.active = enabled
    
    local shouldAlwaysActive = nil
    for _,v in ipairs(self.interactable:getChildren()) do
        --print(tostring(v:getType()))
        if tostring(v:getType()) == "controller" then
            if shouldAlwaysActive == nil then
                --print(true)
                shouldAlwaysActive = true
            end
        else
            --print(false)
            shouldAlwaysActive = false
        end
    end
    if shouldAlwaysActive ~= nil and shouldAlwaysActive == true then
        --print("result")
        self.interactable.active = true
    end
end

function Converter.client_onFixedUpdate( self, timeStep )
    -- Calculate if the converter is enabled client-side to decrease delay
    local enabled = self.seat and (self.converterFunction(self.seat) * (self.inverted and -1 or 1) == 1) or false

    self.interactable:setUvFrameIndex(enabled and 6 or 0)
    self.interactable:setPoseWeight(0, enabled and 1 or 0)
end

function Converter.updateSeat( self )
    self.seat = self.interactable:getSingleParent()
end

function Converter.sv_calculateEnabled( self )
    self:updateSeat()
    
    if self.seat then
        local value = self.converterFunction(self.seat) * (self.inverted and -1 or 1)
        
        if value == 1 then
            self:sv_setEnabled(true, 1)
        elseif value == -1 then
            self:sv_setEnabled(false, -1)
        else
            self:sv_setEnabled(false, 0.0)
        end
    else
        self.interactable.power = 0
        self.interactable.active = false
    end
end

function Converter.server_onFixedUpdate( self, timeStep )
    self:sv_calculateEnabled()
end








W_Converter = class( Converter )
A_Converter = class( Converter )
S_Converter = class( Converter )
D_Converter = class( Converter )

-- Abusing the fact that the host also has a client
function W_Converter.client_onCreate( self )
    self.converterFunction = self.interactable.getSteeringPower
end

function A_Converter.client_onCreate( self )
    self.converterFunction = self.interactable.getSteeringAngle
    self.inverted = true
end

function S_Converter.client_onCreate( self )
    self.converterFunction = self.interactable.getSteeringPower
    self.inverted = true
end

function D_Converter.client_onCreate( self )
    self.converterFunction = self.interactable.getSteeringAngle
end
