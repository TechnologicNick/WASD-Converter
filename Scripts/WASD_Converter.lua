W_Converter = class( nil )
W_Converter.maxChildCount = -1
W_Converter.maxParentCount = 1
W_Converter.connectionInput = sm.interactable.connectionType.power-- + sm.interactable.connectionType.logic
W_Converter.connectionOutput = sm.interactable.connectionType.logic-- + sm.interactable.connectionType.power
W_Converter.colorNormal = sm.color.new( 0x007fffff )
W_Converter.colorHighlight = sm.color.new( 0x3094ffff )
W_Converter.poseWeightCount = 1

A_Converter = class( nil )
A_Converter.maxChildCount = -1
A_Converter.maxParentCount = 1
A_Converter.connectionInput = sm.interactable.connectionType.bearing-- + sm.interactable.connectionType.logic
A_Converter.connectionOutput = sm.interactable.connectionType.logic-- + sm.interactable.connectionType.power
A_Converter.colorNormal = sm.color.new( 0x007fffff )
A_Converter.colorHighlight = sm.color.new( 0x3094ffff )
A_Converter.poseWeightCount = 1

S_Converter = class( nil )
S_Converter.maxChildCount = -1
S_Converter.maxParentCount = 1
S_Converter.connectionInput = sm.interactable.connectionType.power-- + sm.interactable.connectionType.logic
S_Converter.connectionOutput = sm.interactable.connectionType.logic-- + sm.interactable.connectionType.power
S_Converter.colorNormal = sm.color.new( 0x007fffff )
S_Converter.colorHighlight = sm.color.new( 0x3094ffff )
S_Converter.poseWeightCount = 1

D_Converter = class( nil )
D_Converter.maxChildCount = -1
D_Converter.maxParentCount = 1
D_Converter.connectionInput = sm.interactable.connectionType.bearing-- + sm.interactable.connectionType.logic
D_Converter.connectionOutput = sm.interactable.connectionType.logic-- + sm.interactable.connectionType.power
D_Converter.colorNormal = sm.color.new( 0x007fffff )
D_Converter.colorHighlight = sm.color.new( 0x3094ffff )
D_Converter.poseWeightCount = 1

function A_Converter.server_onCreate( self )
    self.parentPoseWeight = 0.5
    self.prevParentPoseWeight = 0.5
end

function D_Converter.server_onCreate( self )
    self.parentPoseWeight = 0.5
    self.prevParentPoseWeight = 0.5
end

function A_Converter.server_onRefresh( self )
    self:server_onCreate()
end

function D_Converter.server_onRefresh( self )
    self:server_onCreate()
end

function W_Converter.server_onFixedUpdate( self, timeStep )
    local parent = self.interactable:getSingleParent()
    if parent then
        if parent:getPower() > 0 then
            --print("W")
            server_setWASDConverterEnabled(self, true, 1.0)
        elseif parent:getPower() < 0 then
            --print("S")
            server_setWASDConverterEnabled(self, false, -1.0)
        else
            server_setWASDConverterEnabled(self, false, 0.0)
        end
    end
end

function A_Converter.server_onFixedUpdate( self, timeStep )
    local parent = self.interactable:getSingleParent()
    if parent then
        if (self.parentPoseWeight < self.prevParentPoseWeight and self.parentPoseWeight < 0.5) or self.parentPoseWeight == 0 then
            --print("A")
            server_setWASDConverterEnabled(self, true, 1.0)
        elseif (self.parentPoseWeight > self.prevParentPoseWeight and self.parentPoseWeight > 0.5) or self.parentPoseWeight == 1 then
            --print("D")
            server_setWASDConverterEnabled(self, false, -1.0)
        else
            server_setWASDConverterEnabled(self, false, 0.0)
        end
        self.prevParentPoseWeight = self.parentPoseWeight
    end
end

function S_Converter.server_onFixedUpdate( self, timeStep )
    local parent = self.interactable:getSingleParent()
    if parent then
        if parent:getPower() < 0 then
            --print("S")
            server_setWASDConverterEnabled(self, true, 1.0)
        elseif parent:getPower() > 0 then
            --print("W")
            server_setWASDConverterEnabled(self, false, -1.0)
        else
            server_setWASDConverterEnabled(self, false, 0.0)
        end
    end
end

function D_Converter.server_onFixedUpdate( self, timeStep )
    local parent = self.interactable:getSingleParent()
    if parent then
        if (self.parentPoseWeight > self.prevParentPoseWeight and self.parentPoseWeight > 0.5) or self.parentPoseWeight == 1 then
            --print("D")
            server_setWASDConverterEnabled(self, true, 1.0)
        elseif (self.parentPoseWeight < self.prevParentPoseWeight and self.parentPoseWeight < 0.5) or self.parentPoseWeight == 0 then
            --print("A")
            server_setWASDConverterEnabled(self, false, -1.0)
        else
            server_setWASDConverterEnabled(self, false, 0.0)
        end
        self.prevParentPoseWeight = self.parentPoseWeight
    end
end

function A_Converter.client_onFixedUpdate( self, timeStep )
    local parent = self.interactable:getSingleParent()
    if parent then
        self.network:sendToServer("server_receivePoseWeight", parent:getPoseWeight(0))
    end
end

function D_Converter.client_onFixedUpdate( self, timeStep )
    local parent = self.interactable:getSingleParent()
    if parent then
        self.network:sendToServer("server_receivePoseWeight", parent:getPoseWeight(0))
    end
end

function A_Converter.server_receivePoseWeight( self, data )
    self.parentPoseWeight = data
end

function D_Converter.server_receivePoseWeight( self, data )
    self.parentPoseWeight = data
end

function server_setWASDConverterEnabled( self, enabled, power )
    if enabled then
        self.network:sendToClients("client_setPoseWeight", 1)
        self.network:sendToClients("client_setUvFrameIndex", 6)
        self.interactable:setActive(true)
    else
        self.network:sendToClients("client_setPoseWeight", 0)
        self.network:sendToClients("client_setUvFrameIndex", 0)
        self.interactable:setActive(false)
    end
    self.interactable:setPower(power)
    
    local shouldAlwaysActive = nil
    for k,v in pairs(self.interactable:getChildren()) do
        if tostring(v:getType()) == "Controller" then
            if shouldAlwaysActive == nil then
                shouldAlwaysActive = true
            end
        else
            shouldAlwaysActive = false
        end
    end
    if shouldAlwaysActive ~= nil and shouldAlwaysActive == true then
        self.interactable:setActive(true)
    end
end

function client_setPoseWeight( self, weight )
    self.interactable:setPoseWeight(0, weight)
end

function W_Converter.client_setPoseWeight( self, weight )
    client_setPoseWeight( self, weight )
end

function A_Converter.client_setPoseWeight( self, weight )
    client_setPoseWeight( self, weight )
end

function S_Converter.client_setPoseWeight( self, weight )
    client_setPoseWeight( self, weight )
end

function D_Converter.client_setPoseWeight( self, weight )
    client_setPoseWeight( self, weight )
end



function client_setUvFrameIndex( self, index )
    self.interactable:setUvFrameIndex(index)
end

function W_Converter.client_setUvFrameIndex( self, index )
    client_setUvFrameIndex(self, index)
end

function A_Converter.client_setUvFrameIndex( self, index )
    client_setUvFrameIndex(self, index)
end

function S_Converter.client_setUvFrameIndex( self, index )
    client_setUvFrameIndex(self, index)
end

function D_Converter.client_setUvFrameIndex( self, index )
    client_setUvFrameIndex(self, index)
end

