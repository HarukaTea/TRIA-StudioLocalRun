--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local Signals = require(RepS.Modules.Data.Signals)
local HarukaLib = require(RepS.Modules.Packages.HarukaLib)

local Add, Empty = HarukaLib.Bin()

local char = script.Parent.Parent :: Model

Add(char.Humanoid.Touched:Connect(function(hit: BasePart)
    if hit and hit:GetAttribute("_action") == "Teleport" then

        if not hit:FindFirstChild("Destination") then
            Signals.CreateHint:Fire("Can not find destination part! Did you forget that?", nil, 6)
            return
        end

        char:PivotTo(hit.Destination.CFrame)

        if hit:GetAttribute("SetCameraFront") then
            local camera = workspace.CurrentCamera

            camera.CFrame = CFrame.new(camera.CFrame.Position, camera.CFrame.Position + hit.Destination.CFrame.LookVector)
        end
    end
end))

--// Clear
char.Humanoid.Died:Once(function()
    Empty()
end)
