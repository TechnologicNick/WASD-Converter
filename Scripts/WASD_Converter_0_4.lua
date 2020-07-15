print("Loaded WASD Converters for 0.4")

Converter = class()
Converter.maxChildCount = -1
Converter.maxParentCount = 1
Converter.connectionInput = sm.interactable.connectionType.power
Converter.connectionOutput = sm.interactable.connectionType.logic
Converter.colorNormal = sm.color.new( 0x007fffff )
Converter.colorHighlight = sm.color.new( 0x3094ffff )
Converter.poseWeightCount = 1













W_Converter = class( Converter )
A_Converter = class( Converter )
S_Converter = class( Converter )
D_Converter = class( Converter )