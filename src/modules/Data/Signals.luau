--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local Signal = require(RepS.Modules.Packages.Signal)

local signals = {
    CreateHint = Signal.new()
}

return signals
