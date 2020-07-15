-- Backwards compatibility

if sm.version:sub(1, 3) == "0.3" then
    dofile("WASD_Converter_0_3.lua")
else
    dofile("WASD_Converter_0_4.lua")
end