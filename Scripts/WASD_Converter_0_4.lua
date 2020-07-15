print("Loaded WASD Converters for 0.4")

Converter = class()
Converter.maxChildCount = -1
Converter.maxParentCount = 1
Converter.connectionInput = sm.interactable.connectionType.power
Converter.connectionOutput = sm.interactable.connectionType.logic
Converter.colorNormal = sm.color.new( 0x007fffff )
Converter.colorHighlight = sm.color.new( 0x3094ffff )
Converter.poseWeightCount = 1

function Converter.client_onCreate( self )
    --((not self.data) or (not self.data.action)) == false
    self.actionName = assert(self.data and self.data.action, "No action found for converter " .. tostring(self.shape.shapeUuid))
    self.actionId = assert(sm.interactable.actions[self.actionName], "Action \"" .. self.actionName .. "\" is not in sm.interactable.actions!")
    
    print(self.actionName, self.actionId)
end

function Converter.client_onFixedUpdate( self, timeStep )
    self.seat = self.interactable:getSingleParent()
    
    -- Check if the player is in the parent seat
    if self:cl_isInSeat() then
        
    end
end

function Converter.cl_isInSeat( self )
    return self.seat and sm.localPlayer.getPlayer().character == self.seat:getSeatCharacter()
end

function Converter.client_onAction( self, controllerAction, state )
    print(controllerAction, state)
end










-- Doing it this way to still support 0.3 without having to change the 0.3 script
W_Converter = class( Converter )
A_Converter = class( Converter )
S_Converter = class( Converter )
D_Converter = class( Converter )